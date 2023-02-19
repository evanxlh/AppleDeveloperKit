//
//  H264Encoder.m
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

#import <VideoToolbox/VideoToolbox.h>
#import "H264Encoder.h"

@interface H264Encoder ()
@property (nonatomic, readwrite) VTCompressionSessionRef encoderSession;
@property (nonatomic, readwrite) CMVideoFormatDescriptionRef videoFormatDescription;
@property (nonatomic, readwrite) NSUInteger frameIndex;
@property (nonatomic, copy) NSData *spsData;
@property (nonatomic, copy) NSData *ppsData;
@end

@implementation H264Encoder

void didEncodeH264SampleBuffer(void * CM_NULLABLE outputCallbackRefCon,
                               void * CM_NULLABLE sourceFrameRefCon,
                               OSStatus status,
                               VTEncodeInfoFlags infoFlags,
                               CM_NULLABLE CMSampleBufferRef sampleBuffer)
{
    H264Encoder *encoder = (__bridge H264Encoder *)outputCallbackRefCon;
    if (status != noErr) {
        H264Error *error = [H264Error errorWithType:H264ErrorTypeEncodeFrame errorCode:status];
        [encoder outputError:error];
        return;
    }

    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }

    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFDictionaryRef attachmentInfo = CFArrayGetValueAtIndex(attachments, 0);

    OSStatus result = noErr;
    BOOL isKeyframe = CFDictionaryContainsKey(attachmentInfo, kCMSampleAttachmentKey_NotSync);
    if (isKeyframe) {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);

        size_t spsSize = 0, spsCount = 0;
        const uint8_t *sps = NULL;

        result = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sps, &spsSize, &spsCount, 0);
        if (result == noErr) {
            // Already found SPS, now check for PPS
            size_t ppsSize = 0, ppsCount = 0;
            const uint8_t *pps = NULL;

            result = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pps, &ppsSize, &ppsCount, 0);
            if (result == noErr) {
                // SPS, PPS are both found
                encoder.spsData = [NSData dataWithBytes:sps length:spsSize];
                encoder.ppsData = [NSData dataWithBytes:pps length:ppsSize];
                [encoder.delegate encoder:encoder didOutputSps:encoder.spsData pps:encoder.ppsData];
            }
        }
    }

    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length = 0, totalLength = 0;
    char *dataPointer = NULL;
    result = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (result == noErr) {
        size_t bufferOffset = 0;
        static const int avccHeaderLength = 4;
        while (bufferOffset < totalLength - avccHeaderLength) {

            // Read NAL Unit length
            uint32_t naluLength = 0;
            memcpy(&naluLength, dataPointer + bufferOffset, avccHeaderLength);
            naluLength = CFSwapInt32BigToHost(naluLength);

            // Output encoded frame data
            NSData *data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + avccHeaderLength) length:naluLength];
            [encoder.delegate encoder:encoder didOutputEncodedFrameData:data isKeyframe:isKeyframe];

            // Move to next NAL Unit in the block buffer
            bufferOffset += (avccHeaderLength + naluLength);
        }
    }
}

- (instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height
{
    if (self = [super init]) {
        _width = width;
        _height = height;
        _frameIndex = 0;
    }
    return self;
}

#pragma mark - Public Functions

- (void)encodeVideoFrame:(CMSampleBufferRef)sampleBuffer
{
    H264Error *error = [self createEncoderSessionIfNeed];
    if (error) {
        [self outputError:error];
        return;
    }

    ++_frameIndex;

    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (imageBuffer == NULL) {
        H264Error *error = [H264Error errorWithType:H264ErrorTypeSampleBuffer errorCode:H264SampleBufferErrorCodeNoImageData];
        [self outputError:error];
        return ;
    }

    CMTime presentationTimeStamp = CMTimeMake(_frameIndex, 1000);
    VTEncodeInfoFlags flags = 0;

    OSStatus status = VTCompressionSessionEncodeFrame(_encoderSession, imageBuffer, presentationTimeStamp, kCMTimeInvalid, NULL, NULL, &flags);
    if (status != noErr) {
        H264Error *error = [H264Error errorWithType:H264ErrorTypeEncodeFrame errorCode:status];
        [self outputError:error];
        return ;
    }

    return ;
}

- (void)endEncoding
{
    OSStatus status = VTCompressionSessionCompleteFrames(_encoderSession, kCMTimeInvalid);
    [self invalidateEncoderSession];

    if (status != noErr) {
        H264Error *error = [H264Error errorWithType:H264ErrorTypeCompleteEncoding errorCode:status];
        [self outputError:error];
        return ;
    }
    return ;
}

#pragma mark - Private Functions

- (H264Error * __nullable)createEncoderSession
{
    OSStatus status = VTCompressionSessionCreate(NULL, (uint32_t)_width, (uint32_t)_height, kCMVideoCodecType_H264, NULL, NULL, NULL, didEncodeH264SampleBuffer, (__bridge void *)self, &_encoderSession);

    if (status != noErr) {
        H264Error *error = [H264Error errorWithType:H264ErrorTypeCreateEncoderSession errorCode:status];
        return error;
    }

    // Set the properties
    VTSessionSetProperty(_encoderSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
    VTSessionSetProperty(_encoderSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);


    // Tell the encoder to start encoding
    VTCompressionSessionPrepareToEncodeFrames(_encoderSession);
    return nil;
}

- (H264Error * __nullable)createEncoderSessionIfNeed
{
    if (self.encoderSession) {
        return nil;
    }

    return [self createEncoderSession];
}

- (void)invalidateEncoderSession
{
    if (self.encoderSession) {
        VTCompressionSessionInvalidate(self.encoderSession);
        CFRelease(_encoderSession);
        _encoderSession = nil;
    }
}



- (void)outputError:(H264Error * __nonnull)error
{
    NSLog(@"%@", error.debugDescription);
    [self.delegate encoder:self didEncounterError:error];
}

@end
