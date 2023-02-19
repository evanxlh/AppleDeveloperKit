//
//  H264Nalu.m
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

#import <CoreFoundation/CFByteOrder.h>
#import "H264Nalu.h"

/**
 +---------------+
 |0|1|2|3|4|5|6|7|
 +-+-+-+-+-+-+-+-+
 |F|NRI| Type |
 +---------------+
 
 F      1bit    forbidden_zero_bit  It's always 0 in H.264 specification.
 NRI    2bits   nal_ref_idc         Indicates that how importance the NALU is.
 
 A value of 00 indicates that the content of the NAL unit is not used
 to reconstruct reference pictures for inter picture prediction.
 Such NAL units can be discarded without risking the integrity of
 the reference pictures.  Values greater than 00 indicate that the
 decoding of the NAL unit is required to maintain the integrity of
 the reference pictures.
 
 In addition to the specification above, according to this RTP
 payload specification, values of NRI greater than 00 indicate the
 relative transport priority, as determined by the encoder.
 
 RTP Payload Format for H.264 Video can use this information to protect more important NAL units
 better than they do less important NAL units.
 
 Priority:
 11  highest
 10  high
 01  normal
 00  lowest
 
 Informative note: Any non-zero value of NRI is handled
 identically in H.264 decoders.  Therefore, receivers need not
 manipulate the value of NRI when passing NAL units to the
 decoder.
 
 Type   5bits   nalu_type           Indicates the type of NALU.
 0           Unspecified
 1-23        NALU    Single NAL Unit                     (单个 NAL 单元包)
 24          STAP-A  Single Time Aggregation Packet      (单一时间的组合包)
 25          STAP-B  Single Time Aggregation Packet      (单一时间的组合包)
 26          MTAP16  Multiple Time Aggregation Packet    (多个时间的组合包)
 27          MTAP24  Multiple Time Aggregation Packet    (多个时间的组合包)
 28          FU-A    Fragmentation Unit                  分片的单元
 29          FU-B    Fragmentation Unit                  分片的单元
 30-31       Unspecified
 */
#pragma pack(push, 1)
typedef union {
    uint8_t data[1];
    
    struct {
        uint8_t nalu_type:5;
        uint8_t nal_ref_idc:2;
        uint8_t forbidden_zero_bit:1; // Alway 0
    }field;
}NaluHeader;
#pragma pack(pop)

/** H264 NAL Unit start code */
const uint32_t NALU_START_CODE_SIZE = 4;
const uint8_t NALU_START_CODE[NALU_START_CODE_SIZE] = { 0x00, 0x00, 0x00, 0x01 };


@implementation H264Nalu

+ (NSString * __nonnull)naluTypeDescription:(uint8_t)naluTypeValue
{
    static NSString * const naluTypeStrings[] = {
        @"0: Unspecified (non-VCL)",
        @"1: Coded slice of a non-IDR picture (VCL)",    // P frame
        @"2: Coded slice data partition A (VCL)",
        @"3: Coded slice data partition B (VCL)",
        @"4: Coded slice data partition C (VCL)",
        @"5: Coded slice of an IDR picture (VCL)",      // I frame
        @"6: Supplemental enhancement information (SEI) (non-VCL)",
        @"7: Sequence parameter set (non-VCL)",         // SPS parameter
        @"8: Picture parameter set (non-VCL)",          // PPS parameter
        @"9: Access unit delimiter (non-VCL)",
        @"10: End of sequence (non-VCL)",
        @"11: End of stream (non-VCL)",
        @"12: Filler data (non-VCL)",
        @"13: Sequence parameter set extension (non-VCL)",
        @"14: Prefix NAL unit (non-VCL)",
        @"15: Subset sequence parameter set (non-VCL)",
        @"16: Reserved (non-VCL)",
        @"17: Reserved (non-VCL)",
        @"18: Reserved (non-VCL)",
        @"19: Coded slice of an auxiliary coded picture without partitioning (non-VCL)",
        @"20: Coded slice extension (non-VCL)",
        @"21: Coded slice extension for depth view components (non-VCL)",
        @"22: Reserved (non-VCL)",
        @"23: Reserved (non-VCL)",
        @"24: STAP-A Single-time aggregation packet (non-VCL)",
        @"25: STAP-B Single-time aggregation packet (non-VCL)",
        @"26: MTAP16 Multi-time aggregation packet (non-VCL)",
        @"27: MTAP24 Multi-time aggregation packet (non-VCL)",
        @"28: FU-A Fragmentation unit (non-VCL)",
        @"29: FU-B Fragmentation unit (non-VCL)",
        @"30: Unspecified (non-VCL)",
        @"31: Unspecified (non-VCL)",
    };
    
    if (naluTypeValue > 31) {
        return [NSString stringWithFormat:@"%i: Invalid NALU type(legal value [0, 31])", naluTypeValue];
    } else {
        return naluTypeStrings[naluTypeValue];
    }
}

+ (H264NaluType)naluTypeFromRawValue:(uint8_t)naluTypeRawValue
{
    switch (naluTypeRawValue) {
        case 1:
            return H264NaluTypeNonIDR;
        case 2:
            return H264NaluTypeDataPartition_A;
        case 3:
            return H264NaluTypeDataPartition_B;
        case 4:
            return H264NaluTypeDataPartition_C;
        case 5:
            return H264NaluTypeIDR;
        case 6:
            return H264NaluTypeSEI;
        case 7:
            return H264NaluTypeSPS;
        case 8:
            return H264NaluTypePPS;
        case 9:
            return H264NaluTypeAccessUnitDelimiter;
        case 10:
            return H264NaluTypeEndOfSequence;
        case 11:
            return H264NaluTypeEndOfStream;
        case 12:
            return H264NaluTypeFillerData;
        default:
            return H264NaluTypeUnSpecified;
    }
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (instancetype)initWithRawBytes:(uint8_t *)rawBytes length:(uint32_t)length
{
    if (self = [super init]) {
        
        if (length < 5) {
            return nil;
        }
        
        _rawBytes = rawBytes;
        _rawByteslength = length;
        
        if (length > 4) {
            if (rawBytes[0] == NALU_START_CODE[0] &&
                rawBytes[1] == NALU_START_CODE[1] &&
                rawBytes[2] == NALU_START_CODE[2] &&
                rawBytes[3] == NALU_START_CODE[3]) {
                
                // NALU start code is correct
                NaluHeader header = { rawBytes[4] };
                _type = [[self class] naluTypeFromRawValue:header.field.nalu_type];
            } else {
                return nil;
            }
        } else {
            _type = H264NaluTypeUnSpecified;
        }
    }
    return self;
}

- (H264Nalu *)copy
{
    uint8_t *dataBytes = malloc(_rawByteslength);
    if (dataBytes == NULL) {
        return nil;
    } else {
        memcpy(dataBytes, _rawBytes, _rawByteslength);
        return [[H264Nalu alloc] initWithRawBytes:dataBytes length:_rawByteslength];
    }
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[H264Nalu class]]) {
        return NO;
    }
    
    H264Nalu *nalu = (H264Nalu *)object;
    if (nalu.rawByteslength != self.rawByteslength) {
        return NO;
    } else {
        return (memcmp(self.rawBytes, nalu.rawBytes, self.rawByteslength) == 0);
    }
}

- (CMBlockBufferRef)createBlockBuffer:(H264Error *__autoreleasing  _Nullable *)error
{
    // Relacing NALU start code with NALU data length.
    uint32_t nalSize = self.rawByteslength - NALU_START_CODE_SIZE;
    nalSize = CFSwapInt32HostToBig(nalSize);
    memcpy(self.rawBytes, &nalSize, NALU_START_CODE_SIZE);
    
    CMBlockBufferRef blockBuffer = NULL;
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, // structureAllocator
                                                         self.rawBytes,
                                                         self.rawByteslength,
                                                         kCFAllocatorNull, // blockAllocator
                                                         NULL,
                                                         0, // Offset
                                                         self.rawByteslength,
                                                         0, // CMBlockBufferFlags
                                                         &blockBuffer);
    
    
    if (status != kCMBlockBufferNoErr) {
        if (error) {
            *error = [H264Error errorWithType:H264ErrorTypeCreateBlockBuffer errorCode:status];
        }
    }
    
    return blockBuffer;
}

- (CMSampleBufferRef)createSampleBufferWithVideoFromatDescription:(CMVideoFormatDescriptionRef)formatDescription
                                                            error:(H264Error *__autoreleasing  _Nullable *)error
{
    CMBlockBufferRef blockBuffer = [self createBlockBuffer:error];
    if (blockBuffer == NULL) {
        return NULL;
    }
    
    CMSampleTimingInfo timeInfo = {
        .duration = kCMTimeInvalid,
        .presentationTimeStamp = kCMTimeZero, // pts
        .decodeTimeStamp = kCMTimeInvalid
    };
    
    CMSampleBufferRef sampleBuffer = NULL;
    OSStatus status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                                blockBuffer,
                                                formatDescription,
                                                1, // numSamples
                                                1, // numSampleTimingEntries
                                                &timeInfo,
                                                0, // numSampleSizeEntries
                                                nil, // sampleSizeArray
                                                &sampleBuffer);
    if (status != noErr) {
        if (error) {
            *error = [H264Error errorWithType:H264ErrorTypeCreateSampleBuffer errorCode:status];
        }
    }
    
    return sampleBuffer;
}

@end

