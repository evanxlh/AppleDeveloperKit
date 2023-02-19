//
//  AudioError.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

import Foundation
import AudioToolbox

/// Error codes defined in Audio File Services.
public enum AudioFileError: Error, CustomDebugStringConvertible {
    case badPropertySize
    case endOfFile
    case fileNotFound
    case invalidChunk
    case invalidFile
    case invalidFilePosition
    case invalidPacketOffset
    case notAllow64BitDataSize
    case notOpen
    case notOptimized
    case permissions
    case unsupportedAudioFileOperation
    case unsupportedDataFormat
    case unsupportedFileType
    case unsupportedProperty
    case unspecifiedError(OSStatus)

    public init(_ osstatus: OSStatus) {
        switch osstatus {
        case kAudioFileBadPropertySizeError:
            self = .badPropertySize
        case kAudioFileEndOfFileError:
            self = .endOfFile
        case kAudioFileFileNotFoundError:
            self = .fileNotFound
        case kAudioFileInvalidChunkError:
            self = .invalidChunk
        case kAudioFileInvalidFileError:
            self = .invalidFile
        case kAudioFilePositionError:
            self = .invalidFilePosition
        case kAudioFileInvalidPacketOffsetError:
            self = .invalidPacketOffset
        case kAudioFileDoesNotAllow64BitDataSizeError:
            self = .notAllow64BitDataSize
        case kAudioFileNotOpenError:
            self = .notOpen
        case kAudioFileNotOptimizedError:
            self = .notOptimized
        case kAudioFilePermissionsError:
            self = .permissions
        case kAudioFileOperationNotSupportedError:
            self = .unsupportedAudioFileOperation
        case kAudioFileUnsupportedDataFormatError:
            self = .unsupportedDataFormat
        case kAudioFileUnsupportedFileTypeError:
            self = .unsupportedFileType
        case kAudioFileUnsupportedPropertyError:
            self = .unsupportedProperty
        default:
            self = .unspecifiedError(osstatus)
        }
    }

    public var rawErrorCode: OSStatus {
        switch self {
        case .badPropertySize:
            return kAudioFileBadPropertySizeError
        case .endOfFile:
            return kAudioFileEndOfFileError
        case .fileNotFound:
            return kAudioFileFileNotFoundError
        case .invalidChunk:
            return kAudioFileInvalidChunkError
        case .invalidFile:
            return kAudioFileInvalidFileError
        case .invalidFilePosition:
            return kAudioFilePositionError
        case .invalidPacketOffset:
            return kAudioFileInvalidPacketOffsetError
        case .notAllow64BitDataSize:
            return kAudioFileDoesNotAllow64BitDataSizeError
        case .notOpen:
            return kAudioFileNotOpenError
        case .notOptimized:
            return kAudioFileNotOptimizedError
        case .permissions:
            return kAudioFilePermissionsError
        case .unsupportedAudioFileOperation:
            return kAudioFileOperationNotSupportedError
        case .unsupportedDataFormat:
            return kAudioFileUnsupportedDataFormatError
        case .unsupportedFileType:
            return kAudioFileUnsupportedFileTypeError
        case .unsupportedProperty:
            return kAudioFileUnsupportedPropertyError
        case .unspecifiedError(let code):
            return code
        }
    }

    public var debugDescription: String {
        switch self {
        case .badPropertySize:
            return "The size of the property data was not correct"
        case .endOfFile:
            return "End of file"
        case .fileNotFound:
            return "File not found"
        case .invalidChunk:
            return "Either the chunk does not exist in the file or it is not supported by the file"
        case .invalidFile:
            return "The file is malformed, or otherwise not a valid instance of an audio file of its type"
        case .invalidFilePosition:
            return "Invalid file position"
        case .invalidPacketOffset:
            return "A packet offset was past the end of the file, or not at the end of the file when a VBR format was written, or a corrupt packet size was read when the packet table was built"
        case .notAllow64BitDataSize:
            return "The file offset was too large for the file type. The AIFF and WAVE file format types have 32-bit file size limits"
        case .notOpen:
            return "The file is closed"
        case .notOptimized:
            return "The chunks following the audio data chunk are preventing the extension of the audio data chunk. To write more data, you must optimize the file"
        case .permissions:
            return "The operation violated the file permissions. For example, an attempt was made to write to a file opened with the kAudioFileReadPermission constant"
        case .unsupportedAudioFileOperation:
            return "The operation cannot be performed. For example, setting the kAudioFilePropertyAudioDataByteCount constant to increase the size of the audio data in a file is not a supported operation. Write the data instead"
        case .unsupportedDataFormat:
            return "The data format is not supported by this file type"
        case .unsupportedFileType:
            return "The file type is not supported"
        case .unsupportedProperty:
            return "The property is not supported"
        case .unspecifiedError(let code):
            return "An unspecified error has occurred, error code = \(code)"
        }
    }

}
