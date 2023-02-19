//
//  AudioInfoCollector.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

import Foundation
import AudioToolbox

public enum AudioInfoCollector {

    /// Get audio file ID3 tags.
    public static func id3TagItems(forAudioFile audioFileURL: URL) -> [ID3TagItem]? {
        var fileID: AudioFileID?
        defer {
            if fileID != nil {
                AudioFileClose(fileID!)
            }
        }

        var status = AudioFileOpenURL(audioFileURL as CFURL, .readPermission, AudioFileTypeID.init(truncating: 0), &fileID)
        guard status == noErr else {
            print("Open audio file failed with error code: \(status), \(audioFileURL) ")
            return nil
        }

        var propertySize: UInt32 = 0
        var isWritable: UInt32 = 0
        status = AudioFileGetPropertyInfo(fileID!, kAudioFilePropertyInfoDictionary, &propertySize, &isWritable)
        guard status == noErr else {
            print("Get audio property info failed with error code: \(status), \(audioFileURL) ")
            return nil
        }

        var infoDictionary: CFDictionary?
        status = AudioFileGetProperty(fileID!, kAudioFilePropertyInfoDictionary, &propertySize, &infoDictionary)
        guard status == noErr else {
            print("Get audio property failed with error code: \(status), \(audioFileURL) ")
            return nil
        }

        let info = infoDictionary as! [String: Any]
        let id3Tags: [ID3TagItem] = info.compactMap {
            let field = ID3TagField(fieldName: $0.key)!
            return ID3TagItem(field: field, value: $0.value)
        }
        return id3Tags
    }

    /// Get system audio engine supported AudioStreamBasicDescription. */
    public static func availableASBDs(audioFileType: AudioFileType, audioFormatType: AudioFormatType) -> [AudioStreamBasicDescription]? {

        var infoSize: UInt32 = 0
        var inSpecifier = AudioFileTypeAndFormatID(mFileType: audioFileType.id, mFormatID: audioFormatType.id)
        var status = AudioFileGetGlobalInfoSize(
            kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat,
            UInt32(MemoryLayout<AudioFileTypeAndFormatID>.size),
            &inSpecifier,
            &infoSize
        )

        guard status == noErr else {
            print("AudioFileGetGlobalInfoSize failed: \(AudioFileError(status))")
            return nil
        }

        let asbdSize = MemoryLayout<AudioStreamBasicDescription>.size
        let asbdCount = Int(infoSize) / asbdSize
        let asbdsBuffer = UnsafeMutableBufferPointer<AudioStreamBasicDescription>.allocate(capacity: asbdCount)
        let rawBuffer = UnsafeMutableRawBufferPointer(asbdsBuffer)
        defer { asbdsBuffer.deallocate() }

        status = AudioFileGetGlobalInfo(
            kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat,
            UInt32(asbdSize),
            &inSpecifier,
            &infoSize,
            rawBuffer.baseAddress!
        )

        guard status == noErr else {
            print("AudioFileGetGlobalInfo failed: \(AudioFileError(status))")
            return nil
        }

        var asbds = [AudioStreamBasicDescription]()
        asbdsBuffer.forEach({ asbds.append($0) })
        return asbds
    }

}
