//
//  H264Nalu.h
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "H264Error.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, H264NaluType) {
    /**
     Unspecified, for reserved or this decoder/encoder not supported type,
     we regard them as `Unspecified` type.
     */
    H264NaluTypeUnSpecified,

    /** Coded slice of a non-IDR picture, P frame. */
    H264NaluTypeNonIDR,

    /** Coded slice data partition A */
    H264NaluTypeDataPartition_A,

    /** Coded slice data partition B */
    H264NaluTypeDataPartition_B,

    /** Coded slice data partition C */
    H264NaluTypeDataPartition_C,

    /** Coded slice of an IDR picture, I frame. */
    H264NaluTypeIDR,

    /** Supplemental enhancement information */
    H264NaluTypeSEI,

    /** Sequence parameter set */
    H264NaluTypeSPS,

    /** Picture parameter set */
    H264NaluTypePPS,

    /** Access unit delimiter */
    H264NaluTypeAccessUnitDelimiter,

    /** End of sequence */
    H264NaluTypeEndOfSequence,

    /** End of stream */
    H264NaluTypeEndOfStream,

    /** Filler data */
    H264NaluTypeFillerData
};

/**
 Network Abstraction Layer Unit

 The NAL is specified to format that data and provide header information in a manner appropriate for conveyance
 on a variety of communication channels or storage media.

 Each NAL unit can be preceded by `a start code prefix` + `data` + `extra padding bytes` in the byte stream format.

 @note You can compare wether the two NALUs have the same content or not by `-isEqualTo:`.

 @warning NALU always start 4 bytes start code[0x00, 0x00, 0x00, 0x01].

 @ref T-REC-H.264-200305-S!!PDF-E.pdf
 @ref http://stackoverflow.com/questions/29525000/how-to-use-videotoolbox-to-decompress-h-264-video-stream/
 */
@interface H264Nalu : NSObject

@property (nonatomic, readonly) H264NaluType type;
@property (nonatomic, readonly) uint32_t rawByteslength;
@property (nonatomic, readonly) uint8_t *rawBytes;

/**
 Get NALU type description.
 @param naluTypeRawValue  legal value: [0, 31]
 */
+ (NSString *)naluTypeDescription:(uint8_t)naluTypeRawValue;

+ (H264NaluType)naluTypeFromRawValue:(uint8_t)naluTypeRawValue;

- (instancetype _Nullable)init NS_UNAVAILABLE;

/**
 NALU always start 4 bytes start code[0x00, 0x00, 0x00, 0x01].
 If not starts with 4 bytes start code, return nil.
 */
- (instancetype _Nullable)initWithRawBytes:(uint8_t *)rawBytes length:(uint32_t)length;

/** Create CMBlockBufferRef to store video frame data based on NAL Unit data. */
- (CMBlockBufferRef _Nullable)createBlockBuffer:(H264Error * _Nullable * _Nullable)error;

- (CMSampleBufferRef _Nullable)createSampleBufferWithVideoFromatDescription:(CMVideoFormatDescriptionRef)formatDescription
                                                                      error:(H264Error * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
