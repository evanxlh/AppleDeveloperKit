//
//  H264Error.h
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

#import <Foundation/Foundation.h>

/*!
 Apple OSStatus lookup
 https://www.osstatus.com
 */

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, H264ErrorType) {
    H264ErrorTypeVideoFormatDescription,
    H264ErrorTypeCreateDecoderSession,
    H264ErrorTypeCreateEncoderSession,
    H264ErrorTypeDecodeFrame,
    H264ErrorTypeEncodeFrame,
    H264ErrorTypeCompleteEncoding,
    H264ErrorTypeCreateBlockBuffer,
    H264ErrorTypeCreateSampleBuffer,
    H264ErrorTypeSampleBuffer,
    H264ErrorTypeParseNalu,
    H264ErrorTypeCommon
};

typedef NS_ENUM(NSInteger, H264CommonErrorCode) {
    H264CommonErrorCodeUnexpected,
    H264CommonErrorCodeNoMemory
};

typedef NS_ENUM(NSInteger, H264ParseNaluErrorCode) {
    H264ParseNaluErrorCodeInvalidNaluPacket,
    H264ParseNaluErrorCodeInvalidNaluType
};

typedef NS_ENUM(NSInteger, H264SampleBufferErrorCode) {
    H264SampleBufferErrorCodeNoImageData
};

/**
 Error handle for H264 decoding/encoding.
 Use `-debugDescription` to log error detail information.
 */
@interface H264Error : NSObject <NSCopying>
@property (nonatomic, assign) H264ErrorType errorType;
@property (nonatomic, assign) NSInteger errorCode;
+ (instancetype)errorWithType:(H264ErrorType)errorType errorCode:(NSInteger)errorCode;
- (instancetype)initWithType:(H264ErrorType)errorType errorCode:(NSInteger)errorCode;
@end

NS_ASSUME_NONNULL_END
