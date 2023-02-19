//
//  H264Decoder.h
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

#import <Foundation/Foundation.h>
#import "H264Nalu.h"

NS_ASSUME_NONNULL_BEGIN

/** The delegate functions will be invoked on the internal thread by FIFO order. */
@class H264Decoder;
@class H264VideoFrame;
@protocol H264DocoderDelegate <NSObject>
- (void)decoder:(H264Decoder *)decoder didOutputVideoFrame:(H264VideoFrame *)videoFrame;
- (void)decoder:(H264Decoder *)decoder didEncounterError:(H264Error *)error;
@end

/**
 This class uses iOS `VideoToolBox.framework` to hard decode H264 video frame, it decodes video frame
 in the current thread, and make sure that the video frame is decoded one by one.

 H264DocoderDelegate is also invoked on the current thread synchronously.
 */
@interface H264Decoder : NSObject

@property (nonatomic, weak, nullable) id <H264DocoderDelegate> delegate;

/**
 `outputPixelFormatType` determines the output pxiel format type of the decode.

 Default value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange*/
@property (nonatomic, assign) OSStatus outputPixelFormatType;

/** Decode NALU object on the current thread. */
- (void)decodeNalu:(H264Nalu *)nalu;

/** Decode NALU raw data bytes on the current thread.*/
- (void)decodeNaluRawBytes:(uint8_t *)naluRawBytes length:(uint32_t)length;
@end

@interface H264VideoFrame : NSObject
@property (nonatomic, readwrite) CVPixelBufferRef frameBuffer;
@property (nonatomic, readwrite) CMTime presentationTimeStamp;
@property (nonatomic, readwrite) CMTime presentationDuration;
@end

NS_ASSUME_NONNULL_END

