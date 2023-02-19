//
//  H264Encoder.h
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

#import <Foundation/Foundation.h>
#import "H264Error.h"

NS_ASSUME_NONNULL_BEGIN

@class H264Encoder;
@protocol H264EncoderDelegate <NSObject>
- (void)encoder:(H264Encoder *)encoder didEncounterError:(H264Error *)error;
- (void)encoder:(H264Encoder *)encoder didOutputSps:(NSData *)sps pps:(NSData *)pps;
- (void)encoder:(H264Encoder *)encoder didOutputEncodedFrameData:(NSData *)encodedFrameData isKeyframe:(BOOL)isKeyframe;
@end

@interface H264Encoder : NSObject

@property (nonatomic, weak, nullable) id <H264EncoderDelegate> delegate;
@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;

- (void)encodeVideoFrame:(CMSampleBufferRef)sampleBuffer;
- (void)endEncoding;
@end

NS_ASSUME_NONNULL_END

