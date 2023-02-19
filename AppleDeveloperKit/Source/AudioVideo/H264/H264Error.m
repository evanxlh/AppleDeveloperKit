//
//  H264Error.m
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

#import <VideoToolbox/VideoToolbox.h>
#import "H264Error.h"

@implementation H264Error

+ (instancetype)errorWithType:(H264ErrorType)errorType errorCode:(NSInteger)errorCode
{
    return [[H264Error alloc] initWithType:errorType errorCode:errorCode];
}

- (instancetype)initWithType:(H264ErrorType)errorType errorCode:(NSInteger)errorCode
{
    if (self = [super init]) {
        _errorType = errorType;
        _errorCode = errorCode;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    H264Error *error = [[H264Error allocWithZone:zone] initWithType:self.errorType errorCode:self.errorCode];
    return error;
}

- (NSString *)debugDescription
{
    NSString *errorTypeString = [self errorTypeString];
    NSString *errorCodeString = nil;

    switch (self.errorType) {
        case H264ErrorTypeCreateDecoderSession:
        case H264ErrorTypeCreateEncoderSession:
        case H264ErrorTypeDecodeFrame:
        case H264ErrorTypeEncodeFrame:
        case H264ErrorTypeCompleteEncoding:
            errorCodeString = [self videoToolboxErrorString:(OSStatus)self.errorCode];
            break;
        case H264ErrorTypeCreateBlockBuffer:
            errorCodeString = [self videoFormatDescriptionErrorString:(OSStatus)self.errorCode];
            break;
        case H264ErrorTypeCreateSampleBuffer:
            errorCodeString = [self sampleBufferCreationErrorString:(OSStatus)self.errorCode];
            break;
        case H264ErrorTypeSampleBuffer:

            break;
        case H264ErrorTypeVideoFormatDescription:
            errorCodeString = [self videoFormatDescriptionErrorString:(OSStatus)self.errorCode];
            break;
        case H264ErrorTypeParseNalu:
            errorCodeString = [self parseNaluErrorString:self.errorCode];
            break;
        case H264ErrorTypeCommon:
            errorCodeString = [self commonErrorString:self.errorCode];
            break;
    }
    return [NSString stringWithFormat:@"%@: %@", errorTypeString, errorCodeString];
}

#pragma mark - Internal Functions

- (NSString *)errorTypeString
{
    switch (self.errorType) {
        case H264ErrorTypeVideoFormatDescription:
            return @"H264ErrorTypeVideoFormatDescription";
        case H264ErrorTypeCreateDecoderSession:
            return @"H264ErrorTypeCreateDecoderSession";
        case H264ErrorTypeCreateBlockBuffer:
            return @"H264ErrorTypeCreateBlockBuffer";
        case H264ErrorTypeCreateSampleBuffer:
            return @"H264ErrorTypeCreateSampleBuffer";
        case H264ErrorTypeDecodeFrame:
            return @"H264ErrorTypeDecodeFrame";
        case H264ErrorTypeParseNalu:
            return @"H264ErrorTypeParseNalu";
            break;
        case H264ErrorTypeCommon:
            return @"H264ErrorTypeCommon";
        default:
            return @"UnknownErrorType";
    }
}

- (NSString *)parseNaluErrorString:(H264ParseNaluErrorCode)errorCode
{
    switch (errorCode) {
        case H264ParseNaluErrorCodeInvalidNaluPacket:
            return @"Invalid H264 NALU packet";
        case H264ParseNaluErrorCodeInvalidNaluType:
            return @"Invalid NALU type";
    }
}

- (NSString *)commonErrorString:(H264CommonErrorCode)errorCode
{
    switch (errorCode) {
        case H264CommonErrorCodeNoMemory:
            return @"No enough memory for allocating buffer";
        case H264CommonErrorCodeUnexpected:
            return @"Unexpected error";
    }
}

- (NSString *)videoToolboxErrorString:(OSStatus)errorCode
{
    switch (errorCode) {
        case kVTPropertyNotSupportedErr:
            return [NSString stringWithFormat:@"kVTPropertyNotSupportedErr(%li)", (long)errorCode];
        case kVTPropertyReadOnlyErr:
            return [NSString stringWithFormat:@"kVTPropertyReadOnlyErr(%li)", (long)errorCode];
        case kVTParameterErr:
            return [NSString stringWithFormat:@"kVTParameterErr(%li)", (long)errorCode];
        case kVTInvalidSessionErr:
            return [NSString stringWithFormat:@"kVTInvalidSessionErr(%li)", (long)errorCode];
        case kVTAllocationFailedErr:
            return [NSString stringWithFormat:@"kVTAllocationFailedErr(%li)", (long)errorCode];
        case kVTPixelTransferNotSupportedErr:
            return [NSString stringWithFormat:@"kVTPixelTransferNotSupportedErr(%li)", (long)errorCode];
        case kVTCouldNotFindVideoDecoderErr:
            return [NSString stringWithFormat:@"kVTCouldNotFindVideoDecoderErr(%li)", (long)errorCode];
        case kVTCouldNotCreateInstanceErr:
            return [NSString stringWithFormat:@"kVTCouldNotCreateInstanceErr(%li)", (long)errorCode];
        case kVTCouldNotFindVideoEncoderErr:
            return [NSString stringWithFormat:@"kVTCouldNotFindVideoEncoderErr(%li)", (long)errorCode];
        case kVTVideoDecoderBadDataErr:
            return [NSString stringWithFormat:@"kVTVideoDecoderBadDataErr(%li)", (long)errorCode];
        case kVTVideoDecoderUnsupportedDataFormatErr:
            return [NSString stringWithFormat:@"kVTVideoDecoderUnsupportedDataFormatErr(%li)", (long)errorCode];
        case kVTVideoDecoderMalfunctionErr:
            return [NSString stringWithFormat:@"kVTVideoDecoderMalfunctionErr(%li)", (long)errorCode];
        case kVTVideoEncoderMalfunctionErr:
            return [NSString stringWithFormat:@"kVTVideoEncoderMalfunctionErr(%li)", (long)errorCode];
        case kVTVideoDecoderNotAvailableNowErr:
            return [NSString stringWithFormat:@"kVTVideoDecoderNotAvailableNowErr(%li)", (long)errorCode];
        case kVTImageRotationNotSupportedErr:
            return [NSString stringWithFormat:@"kVTImageRotationNotSupportedErr(%li)", (long)errorCode];
        case kVTVideoEncoderNotAvailableNowErr:
            return [NSString stringWithFormat:@"kVTVideoEncoderNotAvailableNowErr(%li)", (long)errorCode];
        case kVTFormatDescriptionChangeNotSupportedErr:
            return [NSString stringWithFormat:@"kVTFormatDescriptionChangeNotSupportedErr(%li)", (long)errorCode];
        case kVTInsufficientSourceColorDataErr:
            return [NSString stringWithFormat:@"kVTInsufficientSourceColorDataErr(%li)", (long)errorCode];
        case kVTCouldNotCreateColorCorrectionDataErr:
            return [NSString stringWithFormat:@"kVTCouldNotCreateColorCorrectionDataErr(%li)", (long)errorCode];
        case kVTColorSyncTransformConvertFailedErr:
            return [NSString stringWithFormat:@"kVTColorSyncTransformConvertFailedErr(%li)", (long)errorCode];
        case kVTVideoDecoderAuthorizationErr:
            return [NSString stringWithFormat:@"kVTVideoDecoderAuthorizationErr(%li)", (long)errorCode];
        case kVTVideoEncoderAuthorizationErr:
            return [NSString stringWithFormat:@"kVTVideoEncoderAuthorizationErr(%li)", (long)errorCode];
        case kVTColorCorrectionPixelTransferFailedErr:
            return [NSString stringWithFormat:@"kVTColorCorrectionPixelTransferFailedErr(%li)", (long)errorCode];
        case kVTMultiPassStorageIdentifierMismatchErr:
            return [NSString stringWithFormat:@"kVTMultiPassStorageIdentifierMismatchErr(%li)", (long)errorCode];
        case kVTMultiPassStorageInvalidErr:
            return [NSString stringWithFormat:@"kVTMultiPassStorageInvalidErr(%li)", (long)errorCode];
        case kVTFrameSiloInvalidTimeStampErr:
            return [NSString stringWithFormat:@"kVTFrameSiloInvalidTimeStampErr(%li)", (long)errorCode];
        case kVTFrameSiloInvalidTimeRangeErr:
            return [NSString stringWithFormat:@"kVTFrameSiloInvalidTimeRangeErr(%li)", (long)errorCode];
        case kVTCouldNotFindTemporalFilterErr:
            return [NSString stringWithFormat:@"kVTCouldNotFindTemporalFilterErr(%li)", (long)errorCode];
        case kVTPixelTransferNotPermittedErr:
            return [NSString stringWithFormat:@"kVTPixelTransferNotPermittedErr(%li)", (long)errorCode];
        case kVTColorCorrectionImageRotationFailedErr:
            return [NSString stringWithFormat:@"kVTColorCorrectionImageRotationFailedErr(%li)", (long)errorCode];
        default:
            return [NSString stringWithFormat:@"UnkonwError(%li)", (long)errorCode];
    }
}

- (NSString *)blockBufferErrorString:(OSStatus)errorCode
{
    switch (errorCode) {
        case kCMBlockBufferNoErr:
            return [NSString stringWithFormat:@"kCMBlockBufferNoErr(%li)", (long)errorCode];
        case kCMBlockBufferStructureAllocationFailedErr:
            return [NSString stringWithFormat:@"kCMBlockBufferStructureAllocationFailedErr(%li)", (long)errorCode];
        case kCMBlockBufferBlockAllocationFailedErr:
            return [NSString stringWithFormat:@"kCMBlockBufferBlockAllocationFailedErr(%li)", (long)errorCode];
        case kCMBlockBufferBadCustomBlockSourceErr:
            return [NSString stringWithFormat:@"kCMBlockBufferBadCustomBlockSourceErr(%li)", (long)errorCode];
        case kCMBlockBufferBadOffsetParameterErr:
            return [NSString stringWithFormat:@"kCMBlockBufferBadOffsetParameterErr(%li)", (long)errorCode];
        case kCMBlockBufferBadLengthParameterErr:
            return [NSString stringWithFormat:@"kCMBlockBufferBadLengthParameterErr(%li)", (long)errorCode];
        case kCMBlockBufferBadPointerParameterErr:
            return [NSString stringWithFormat:@"kCMBlockBufferBadPointerParameterErr(%li)", (long)errorCode];
        case kCMBlockBufferEmptyBBufErr:
            return [NSString stringWithFormat:@"kCMBlockBufferEmptyBBufErr(%li)", (long)errorCode];
        case kCMBlockBufferUnallocatedBlockErr:
            return [NSString stringWithFormat:@"kCMBlockBufferUnallocatedBlockErr(%li)", (long)errorCode];
        case kCMBlockBufferInsufficientSpaceErr:
            return [NSString stringWithFormat:@"kCMBlockBufferInsufficientSpaceErr(%li)", (long)errorCode];
        default:
            return [NSString stringWithFormat:@"UnkonwError(%li)", (long)errorCode];
    }
}

- (NSString *)sampleBufferCreationErrorString:(OSStatus)errorCode
{
    switch (errorCode) {
        case kCMSampleBufferError_AllocationFailed:
            return [NSString stringWithFormat:@"kCMSampleBufferError_AllocationFailed(%li)", (long)errorCode];
        case kCMSampleBufferError_RequiredParameterMissing:
            return [NSString stringWithFormat:@"kCMSampleBufferError_RequiredParameterMissing(%li)", (long)errorCode];
        case kCMSampleBufferError_AlreadyHasDataBuffer:
            return [NSString stringWithFormat:@"kCMSampleBufferError_AlreadyHasDataBuffer(%li)", (long)errorCode];
        case kCMSampleBufferError_BufferNotReady:
            return [NSString stringWithFormat:@"kCMSampleBufferError_BufferNotReady(%li)", (long)errorCode];
        case kCMSampleBufferError_SampleIndexOutOfRange:
            return [NSString stringWithFormat:@"kCMSampleBufferError_SampleIndexOutOfRange(%li)", (long)errorCode];
        case kCMSampleBufferError_BufferHasNoSampleSizes:
            return [NSString stringWithFormat:@"kCMSampleBufferError_BufferHasNoSampleSizes(%li)", (long)errorCode];
        case kCMSampleBufferError_BufferHasNoSampleTimingInfo:
            return [NSString stringWithFormat:@"kCMSampleBufferError_BufferHasNoSampleTimingInfo(%li)", (long)errorCode];
        case kCMSampleBufferError_ArrayTooSmall:
            return [NSString stringWithFormat:@"kCMSampleBufferError_ArrayTooSmall(%li)", (long)errorCode];
        case kCMSampleBufferError_InvalidEntryCount:
            return [NSString stringWithFormat:@"kCMSampleBufferError_InvalidEntryCount(%li)", (long)errorCode];
        case kCMSampleBufferError_CannotSubdivide:
            return [NSString stringWithFormat:@"kCMSampleBufferError_CannotSubdivide(%li)", (long)errorCode];
        case kCMSampleBufferError_SampleTimingInfoInvalid:
            return [NSString stringWithFormat:@"kCMSampleBufferError_SampleTimingInfoInvalid(%li)", (long)errorCode];
        case kCMSampleBufferError_InvalidMediaTypeForOperation:
            return [NSString stringWithFormat:@"kCMSampleBufferError_InvalidMediaTypeForOperation(%li)", (long)errorCode];
        case kCMSampleBufferError_InvalidSampleData:
            return [NSString stringWithFormat:@"kCMSampleBufferError_InvalidSampleData(%li)", (long)errorCode];
        case kCMSampleBufferError_InvalidMediaFormat:
            return [NSString stringWithFormat:@"kCMSampleBufferError_InvalidMediaFormat(%li)", (long)errorCode];
        case kCMSampleBufferError_Invalidated:
            return [NSString stringWithFormat:@"kCMSampleBufferError_Invalidated(%li)", (long)errorCode];
        case kCMSampleBufferError_DataFailed:
            return [NSString stringWithFormat:@"kCMSampleBufferError_DataFailed(%li)", (long)errorCode];
        case kCMSampleBufferError_DataCanceled:
            return [NSString stringWithFormat:@"kCMSampleBufferError_DataCanceled(%li)", (long)errorCode];
        default:
            return [NSString stringWithFormat:@"UnkonwError(%li)", (long)errorCode];
    }
}

- (NSString *)sampleBufferErrorString:(OSStatus)errorCode
{
    switch (errorCode) {
        case H264SampleBufferErrorCodeNoImageData:
            return [NSString stringWithFormat:@"H264ErrorTypeSampleBuffer(%li)", (long)errorCode];
        default:
            return [NSString stringWithFormat:@"H264ErrorTypeSampleBuffer UnkonwErrorCode(%li)", (long)errorCode];
    }
}

- (NSString *)videoFormatDescriptionErrorString:(OSStatus)errorCode
{
    switch (errorCode) {
        case kCMFormatDescriptionError_AllocationFailed:
            return [NSString stringWithFormat:@"kCMFormatDescriptionError_AllocationFailed(%li)", (long)errorCode];
        case kCMFormatDescriptionError_ValueNotAvailable:
            return [NSString stringWithFormat:@"kCMFormatDescriptionError_ValueNotAvailable(%li)", (long)errorCode];
        case kCMFormatDescriptionError_InvalidParameter:
            return [NSString stringWithFormat:@"kCMFormatDescriptionError_InvalidParameter(%li)", (long)errorCode];
        default:
            return [NSString stringWithFormat:@"UnkonwError(%li)", (long)errorCode];
    }
}

@end
