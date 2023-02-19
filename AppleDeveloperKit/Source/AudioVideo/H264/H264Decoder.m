//
//  H264Decoder.m
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

#import <VideoToolbox/VTDecompressionSession.h>
#import "H264Decoder.h"
#import "H264Error.h"

@interface H264Decoder ()

@property (nonatomic, readwrite) VTDecompressionSessionRef decoderSession;
@property (nonatomic, readwrite) CMVideoFormatDescriptionRef videoFormatDescription;

/**
 temporarySPS and temporaryPPS are used to mark that SPS, PPS are both received.
 Then, we can use them to compare with decoder current SPS, PPS to determin
 wheter decoder should be recreated or not.
 */
@property (nonatomic, strong) H264Nalu *temporarySPS;
@property (nonatomic, strong) H264Nalu *temporaryPPS;

/** Current decoder's SPS, PPS. */
@property (nonatomic, strong) H264Nalu *decoderSPS;
@property (nonatomic, strong) H264Nalu *decoderPPS;

@end

@implementation H264VideoFrame

- (void)dealloc
{
    CVPixelBufferRelease(_frameBuffer);
}

- (void)setFrameBuffer:(CVPixelBufferRef)frameBuffer
{
    CVPixelBufferRetain(frameBuffer);
    _frameBuffer = frameBuffer;
}

@end

@implementation H264Decoder

/** Decoding video frame callback. */
void decodeVideoFrameCompleted(void * CM_NULLABLE decompressionOutputRefCon,
                               void * CM_NULLABLE sourceFrameRefCon,
                               OSStatus status,
                               VTDecodeInfoFlags infoFlags,
                               CM_NULLABLE CVImageBufferRef imageBuffer,
                               CMTime presentationTimeStamp,
                               CMTime presentationDuration)
{
    H264Decoder *decoder = (__bridge H264Decoder *)decompressionOutputRefCon;

    if (status != noErr) {
        H264Error *error = [H264Error errorWithType:H264ErrorTypeDecodeFrame errorCode:status];
        [decoder outputError:error];
        return;
    }

    if (imageBuffer) {
        H264VideoFrame *decodedFrame = [[H264VideoFrame alloc] init];
        decodedFrame.frameBuffer = (CVPixelBufferRef)imageBuffer;
        decodedFrame.presentationTimeStamp = presentationTimeStamp;
        decodedFrame.presentationDuration = presentationDuration;

        [decoder outputVideoFrame:decodedFrame];
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        _outputPixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    }
    return self;
}

- (void)dealloc
{
    [self invalidateVideoDecoder];
}

- (void)invalidateVideoDecoder
{
    if (self.decoderSession) {
        VTDecompressionSessionInvalidate(_decoderSession);
        CFRelease(_decoderSession);
        _decoderSession = nil;
    }

    if (self.videoFormatDescription) {
        CFRelease(self.videoFormatDescription);
        self.videoFormatDescription = nil;
    }

    self.decoderSPS = nil;
    self.decoderPPS = nil;
}

- (H264Error * _Nullable)createDecoderSession
{
    const uint8_t *paramSets[2] = { self.decoderSPS.rawBytes + 4, self.decoderPPS.rawBytes + 4 };
    // Parameter Sets should be removed 4 bytes nalu start code.
    const size_t paramSetSize[2] = { self.decoderSPS.rawByteslength - 4, self.decoderPPS.rawByteslength - 4};

    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                          2, // Parameter set count
                                                                          paramSets,
                                                                          paramSetSize,
                                                                          4, // NALUnitHeaderLength
                                                                          &_videoFormatDescription);
    if (status != noErr) {
        H264Error *error = [H264Error errorWithType:H264ErrorTypeVideoFormatDescription errorCode:status];
        return error;
    }

    const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };

    // Create values binded to keys
    OSStatus pixelFormatType = self.outputPixelFormatType;
    CFNumberRef pixelFormatTypeRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &pixelFormatType);
    const void *values[] = { pixelFormatTypeRef };

    CFDictionaryRef destinationImageBufferAttrs = CFDictionaryCreate(kCFAllocatorDefault, keys, values, 1, NULL, NULL);

    // The decoder callback
    VTDecompressionOutputCallbackRecord outputCallbackRecord;
    outputCallbackRecord.decompressionOutputCallback = decodeVideoFrameCompleted;
    outputCallbackRecord.decompressionOutputRefCon = (__bridge void * _Nullable)(self);

    // Create decoder with above parameters
    status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                          self.videoFormatDescription,
                                          NULL, // videoDecoderSpecification
                                          destinationImageBufferAttrs,
                                          &outputCallbackRecord,
                                          &_decoderSession);

    H264Error *error = nil;

    if (status != noErr) {
        error = [H264Error errorWithType:H264ErrorTypeCreateDecoderSession errorCode:status];
    }

    CFRelease(destinationImageBufferAttrs);
    CFRelease(pixelFormatTypeRef);

    return error;
}

- (H264Error * _Nullable)createDecoderSessionIfNeed
{
    if (self.temporarySPS != nil && self.temporaryPPS != nil) {

        // Received SPS and PPS both, then check whether they are changed or not.
        // If changed, we should re-initialize the video decoder.

        // If decoderSPS or decoderPPS is nil, it means that it is the first time to initialize the video decoder.
        BOOL shouldInitDecoder = (self.decoderSPS == nil || self.decoderPPS == nil);
        BOOL isParamSettingsChange = [self.decoderSPS isEqual:self.temporarySPS] || [self.decoderPPS isEqual:self.temporaryPPS];
        shouldInitDecoder = shouldInitDecoder || isParamSettingsChange;

        H264Error *error = nil;

        if (shouldInitDecoder) {
            [self invalidateVideoDecoder];

            self.decoderSPS = [self.temporarySPS copy];
            self.decoderPPS = [self.temporaryPPS copy];

            error = [self createDecoderSession];
            if (error) {
                self.decoderSPS = nil;
                self.decoderPPS = nil;
            }
        }
        // Clear temporary parameter settings.
        self.temporarySPS = nil;
        self.temporaryPPS = nil;

        return error;
    }

    return nil;
}

- (void)decodeNaluRawBytes:(uint8_t *)naluRawBytes length:(uint32_t)length
{
    H264Nalu *nalu = [[H264Nalu alloc] initWithRawBytes:naluRawBytes length:length];
    [self decodeNalu:nalu];
}

- (void)decodeNalu:(H264Nalu *)nalu
{
    if (!nalu) {
        H264Error *error = [H264Error errorWithType:H264ErrorTypeParseNalu errorCode:H264ParseNaluErrorCodeInvalidNaluPacket];
        [self outputError:error];
        return;
    }

    // For the unspecified NALU, no need to decode it, just ignore it.
    if (nalu.type == H264NaluTypeUnSpecified) {
        H264Error *error = [H264Error errorWithType:H264ErrorTypeParseNalu errorCode:H264ParseNaluErrorCodeInvalidNaluType];
        [self outputError:error];
        return;
    }

    H264Error *decodeError = nil;

    switch (nalu.type) {
        case H264NaluTypeSPS:
            self.temporarySPS = [nalu copy];
            break;
        case H264NaluTypePPS:
            self.temporaryPPS = [nalu copy];
            break;
        case H264NaluTypeIDR: // I Frame

            decodeError = [self createDecoderSessionIfNeed];
            if (decodeError) {
                [self outputError:decodeError];
                return;
            }

            decodeError = [self decodeVideoFrame:nalu];
            if (decodeError) {
                [self outputError:decodeError];
                return;
            }
            break;

        case H264NaluTypeNonIDR: // P Frame

            decodeError = [self decodeVideoFrame:nalu];
            if (decodeError) {
                [self outputError:decodeError];
                return;
            }
            break;

        default:
            // This decoder ignores other NALU types.
            break;
    }
}

/** Decode I, P frame. */
- (H264Error *)decodeVideoFrame:(H264Nalu *)nalu
{
    VTDecodeFrameFlags frameFlags = 0;
    VTDecodeInfoFlags infoFlags = 0;

    H264Error *error = nil;
    CMSampleBufferRef sampleBuffer = [nalu createSampleBufferWithVideoFromatDescription:self.videoFormatDescription error:&error];
    if (error) {
        return error;
    }

    OSStatus status = VTDecompressionSessionDecodeFrame(self.decoderSession,
                                                        sampleBuffer,
                                                        frameFlags, // VTDecodeFrameFlags
                                                        NULL, // sourceFrameRefCon
                                                        &infoFlags);

    if (status != noErr) {
        error = [H264Error errorWithType:H264ErrorTypeDecodeFrame errorCode:status];
    }

    CFRelease(sampleBuffer);

    return error;
}

- (void)outputError:(H264Error * __nonnull)error
{
    NSLog(@"%@", error.debugDescription);

    if ([self.delegate respondsToSelector:@selector(decoder:didEncounterError:)]) {
        [self.delegate decoder:self didEncounterError:[error copy]];
    }
}

- (void)outputVideoFrame:(H264VideoFrame *)videoFrame
{
    if ([self.delegate respondsToSelector:@selector(decoder:didOutputVideoFrame:)]) {
        [self.delegate decoder:self didOutputVideoFrame:videoFrame];
    }
}

@end
