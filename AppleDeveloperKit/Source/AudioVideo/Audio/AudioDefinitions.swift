//
//  AudioDefinitions.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

import Foundation
import AudioToolbox
import CoreAudio

/// Audio data format types.
public enum AudioFormatType: Int, CustomDebugStringConvertible {
    case linearPCM
    case ac3
    case x60958AC3
    case appleIMA4
    case mpeg4AAC
    case mpeg4CELP
    case mpeg4HVXC
    case mpeg4TwinVQ
    case mace3
    case mace6
    case ulaw
    case alaw
    case qDesign
    case qDesign2
    case qualComm
    case mpegLayer1
    case mpegLayer2
    case mpegLayer3
    case timeCode
    case midiStream
    case parameterValueStream
    case appleLossless
    case mpeg4AAC_HE
    case mpeg4AAC_LD
    case mpeg4AAC_ELD
    case mpeg4AAC_ELD_SBR
    case mpeg4AAC_ELD_V2
    case mpeg4AAC_HE_V2
    case mpeg4AAC_Spatial
    case amr
    case amr_WB
    case audible
    case iLBC
    case dviIntelIMA
    case microsoftGSM
    case aes3
    case enhancedAC3
    case flac
    case opus

    public var id: AudioFormatID {
        switch self {
        case .linearPCM:
            return kAudioFormatLinearPCM
        case .ac3:
            return kAudioFormatAC3
        case .x60958AC3:
            return kAudioFormat60958AC3
        case .appleIMA4:
            return kAudioFormatAppleIMA4
        case .mpeg4AAC:
            return kAudioFormatMPEG4AAC
        case .mpeg4CELP:
            return kAudioFormatMPEG4CELP
        case .mpeg4HVXC:
            return kAudioFormatMPEG4HVXC
        case .mpeg4TwinVQ:
            return kAudioFormatMPEG4TwinVQ
        case .mace3:
            return kAudioFormatMACE3
        case .mace6:
            return kAudioFormatMACE6
        case .ulaw:
            return kAudioFormatULaw
        case .alaw:
            return kAudioFormatALaw
        case .qDesign:
            return kAudioFormatQDesign
        case .qDesign2:
            return kAudioFormatQDesign2
        case .qualComm:
            return kAudioFormatQUALCOMM
        case .mpegLayer1:
            return kAudioFormatMPEGLayer1
        case .mpegLayer2:
            return kAudioFormatMPEGLayer2
        case .mpegLayer3:
            return kAudioFormatMPEGLayer3
        case .timeCode:
            return kAudioFormatTimeCode
        case .midiStream:
            return kAudioFormatMIDIStream
        case .parameterValueStream:
            return kAudioFormatParameterValueStream
        case .appleLossless:
            return kAudioFormatAppleLossless
        case .mpeg4AAC_HE:
            return kAudioFormatMPEG4AAC_HE
        case .mpeg4AAC_LD:
            return kAudioFormatMPEG4AAC_LD
        case .mpeg4AAC_ELD:
            return kAudioFormatMPEG4AAC_ELD
        case .mpeg4AAC_ELD_SBR:
            return kAudioFormatMPEG4AAC_ELD_SBR
        case .mpeg4AAC_ELD_V2:
            return kAudioFormatMPEG4AAC_ELD_V2
        case .mpeg4AAC_HE_V2:
            return kAudioFormatMPEG4AAC_HE_V2
        case .mpeg4AAC_Spatial:
            return kAudioFormatMPEG4AAC_Spatial
        case .amr:
            return kAudioFormatAMR
        case .amr_WB:
            return kAudioFormatAMR_WB
        case .audible:
            return kAudioFormatAudible
        case .iLBC:
            return kAudioFormatiLBC
        case .dviIntelIMA:
            return kAudioFormatDVIIntelIMA
        case .microsoftGSM:
            return kAudioFormatMicrosoftGSM
        case .aes3:
            return kAudioFormatAES3
        case .enhancedAC3:
            return kAudioFormatEnhancedAC3
        case .flac:
            return kAudioFormatFLAC
        case .opus:
            return kAudioFormatOpus
        }
    }

    public var debugDescription: String {
        return AVHelper.fourCharCodeString(for: id)
    }

}

/** Audio file continer types. */
public enum AudioFileType: Int, CustomDebugStringConvertible {
    case aac_adts
    case ac3
    case aifc
    case aiff
    case amr
    case caf
    case flac
    case m4a
    case m4b
    case mp1
    case mp2
    case mp3
    case mpeg4
    case next
    case rf64
    case soundDesigner2
    case wave
    case x3gp
    case x3gp2

    public var id: AudioFileTypeID {
        switch self {
        case .aac_adts:
            return kAudioFileAAC_ADTSType
        case .ac3:
            return kAudioFileAC3Type
        case .aifc:
            return kAudioFileAIFCType
        case .aiff:
            return kAudioFileAIFFType
        case .amr:
            return kAudioFileAMRType
        case .caf:
            return kAudioFileCAFType
        case .flac:
            return kAudioFileFLACType
        case .m4a:
            return kAudioFileM4AType
        case .m4b:
            return kAudioFileM4BType
        case .mp1:
            return kAudioFileMP1Type
        case .mp2:
            return kAudioFileMP2Type
        case .mp3:
            return kAudioFileMP3Type
        case .mpeg4:
            return kAudioFileMPEG4Type
        case .next:
            return kAudioFileNextType
        case .rf64:
            return kAudioFileRF64Type
        case .soundDesigner2:
            return kAudioFileSoundDesigner2Type
        case .wave:
            return kAudioFileWAVEType
        case .x3gp:
            return kAudioFile3GPType
        case .x3gp2:
            return kAudioFile3GP2Type
        }
    }

    public var debugDescription: String {
        return AVHelper.fourCharCodeString(for: id)
    }

}

public enum ID3TagField: Int, CaseIterable, CustomDebugStringConvertible {
    case artist
    case lyricist
    case composer
    case album
    case title
    case subtitle
    case genre
    case approximateDuration
    case trackNumber
    case comments
    case copyright
    case year
    case channelLayout
    case encodingApplication
    case isrc
    case keySignature
    case nominalBitRate
    case recordedDate
    case sourceBitDepth
    case sourceEncoder

    /// Beats per minute, or BPM, is a term for measuring the tempo of a piece of music.
    /// "Tempo" is a musical term for the pace, or speed of a piece. Beats per minute is the unit of measurement for measuring tempo.
    /// A "beat" is the standard measurement for a length of a piece of music. Different pieces are written in different time signatures,
    /// and time signatures determine the value of a beat. For example, a time signature of 4/4 indicates that a quarter note (1/4) is one full beat,
    /// and that there are 4 beats in each measure of the song. A song written in 4/4 will have a different tempo when played in a different time signature,
    /// because the value of the beat and the number of beats per measure will change,
    /// and this difference in tempo is shown by a difference in the number of beats per minute in the song.
    case tempo
    case timeSignature

    public init?(fieldName: String) {
        if let field = Self.allCases.filter({ $0.name == fieldName }).first {
            self = field
        } else {
            return nil
        }
    }

    public var name: String {
        switch self {
        case .artist:
            return kAFInfoDictionary_Artist // artist
        case .lyricist:
            return kAFInfoDictionary_Lyricist // lyricist
        case .composer:
            return kAFInfoDictionary_Composer // composer
        case .album:
            return kAFInfoDictionary_Album // album
        case .title:
            return kAFInfoDictionary_Title // title
        case .subtitle:
            return kAFInfoDictionary_SubTitle // subtitle
        case .genre:
            return kAFInfoDictionary_Genre // genre
        case .approximateDuration:
            return kAFInfoDictionary_ApproximateDurationInSeconds // approximate duration in seconds
        case .trackNumber:
            return kAFInfoDictionary_TrackNumber // track number
        case .comments:
            return kAFInfoDictionary_Comments // comments
        case .copyright:
            return kAFInfoDictionary_Copyright // copyright
        case .year:
            return kAFInfoDictionary_Year // year
        case .channelLayout:
            return kAFInfoDictionary_ChannelLayout // channel layout
        case .encodingApplication:
            return kAFInfoDictionary_EncodingApplication // encoding application
        case .isrc:
            return kAFInfoDictionary_ISRC // ISRC (International Standard Recording Code)
        case .keySignature:
            return kAFInfoDictionary_KeySignature // key signature
        case .nominalBitRate:
            return kAFInfoDictionary_NominalBitRate // nominal bit rate
        case .recordedDate:
            return kAFInfoDictionary_RecordedDate // recorded date
        case .sourceBitDepth:
            return kAFInfoDictionary_SourceBitDepth // source bit depth
        case .sourceEncoder:
            return kAFInfoDictionary_SourceEncoder // source encoder
        case .tempo:
            return kAFInfoDictionary_Tempo // tempo (bpm)
        case .timeSignature:
            return kAFInfoDictionary_TimeSignature // time signature
        }
    }

    public var debugDescription: String {
        return name
    }

}

public struct ID3TagItem: CustomDebugStringConvertible {
    public var field: ID3TagField
    public var value: Any

    public var debugDescription: String {
        return "\(field.name): \(value)"
    }
}

public enum AudioFileProperty: Int, CaseIterable {
    case fileFormat
    case dataFormat
    case isOptimized
    case magicCookieData
    case audioDataByteCount
    case audioDataPacketCount
    case maximumPacketSize
    case dataOffset
    case channelLayout
    case deferSizeUpdates
    case dataFormatName
    case markerList
    case regionList
    case packetToFrame
    case frameToPacket
    case packetToByte
    case byteToPacket
    case chunkIDs
    case infoDictionary
    case packetTableInfo
    case formatList
    case packetSizeUpperBound
    case reserveDuration
    case estimatedDuration
    case bitRate
    case id3Tag
    case sourceBitDepth
    case albumArtwork
    case audioTrackCount
    case useAudioTrack

    public init?(propertyID: AudioFilePropertyID) {
        if let property = Self.allCases.filter({ $0.id == propertyID }).first {
            self = property
        } else {
            return nil
        }
    }

    public var id: AudioFilePropertyID {
        switch self {
        case .fileFormat:
            return kAudioFilePropertyFileFormat
        case .dataFormat:
            return kAudioFilePropertyDataFormat
        case .isOptimized:
            return kAudioFilePropertyIsOptimized
        case .magicCookieData:
            return kAudioFilePropertyMagicCookieData
        case .audioDataByteCount:
            return kAudioFilePropertyAudioDataByteCount
        case .audioDataPacketCount:
            return kAudioFilePropertyAudioDataPacketCount
        case .maximumPacketSize:
            return kAudioFilePropertyMaximumPacketSize
        case .dataOffset:
            return kAudioFilePropertyDataOffset
        case .channelLayout:
            return kAudioFilePropertyChannelLayout
        case .deferSizeUpdates:
            return kAudioFilePropertyDeferSizeUpdates
        case .dataFormatName:
            return kAudioFilePropertyDataFormatName
        case .markerList:
            return kAudioFilePropertyMarkerList
        case .regionList:
            return kAudioFilePropertyRegionList
        case .packetToFrame:
            return kAudioFilePropertyPacketToFrame
        case .frameToPacket:
            return kAudioFilePropertyFrameToPacket
        case .packetToByte:
            return kAudioFilePropertyPacketToByte
        case .byteToPacket:
            return kAudioFilePropertyByteToPacket
        case .chunkIDs:
            return kAudioFilePropertyChunkIDs
        case .infoDictionary:
            return kAudioFilePropertyInfoDictionary
        case .packetTableInfo:
            return kAudioFilePropertyPacketTableInfo
        case .formatList:
            return kAudioFilePropertyFormatList
        case .packetSizeUpperBound:
            return kAudioFilePropertyPacketSizeUpperBound
        case .reserveDuration:
            return kAudioFilePropertyReserveDuration
        case .estimatedDuration:
            return kAudioFilePropertyEstimatedDuration
        case .bitRate:
            return kAudioFilePropertyBitRate
        case .id3Tag:
            return kAudioFilePropertyID3Tag
        case .sourceBitDepth:
            return kAudioFilePropertySourceBitDepth
        case .albumArtwork:
            return kAudioFilePropertyAlbumArtwork
        case .audioTrackCount:
            return kAudioFilePropertyAudioTrackCount
        case .useAudioTrack:
            return kAudioFilePropertyUseAudioTrack
        }
    }

    public var fourCharCodeString: String {
        return AVHelper.fourCharCodeString(for: id)
    }

}

public enum AudioFileGlobalInfoProperty: Int, CaseIterable {
    case readableTypes
    case writableTypes
    case fileTypeName
    case availableStreamDescriptionsForFormat
    case availableFormatIDs
    case allExtensions
    case allHFSTypeCodes
    case allUTIs
    case allMIMETypes
    case extensionsForType
    case hfsTypeCodesForType
    case utisForType
    case mimeTypesForType
    case typesForMIMEType
    case typesForUTI
    case typesForHFSTypeCode
    case typesForExtension

    public init?(globalInfoProperty: AudioFilePropertyID) {
        let property = Self.allCases.filter({ $0.id == globalInfoProperty }).first
        if property != nil {
            self = property!
        } else {
            return nil
        }
    }

    public var id: AudioFilePropertyID {
        switch self {
        case .readableTypes:
            return kAudioFileGlobalInfo_ReadableTypes
        case .writableTypes:
            return kAudioFileGlobalInfo_WritableTypes
        case .fileTypeName:
            return kAudioFileGlobalInfo_FileTypeName
        case .availableStreamDescriptionsForFormat:
            return kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat
        case .availableFormatIDs:
            return kAudioFileGlobalInfo_AvailableFormatIDs
        case .allExtensions:
            return kAudioFileGlobalInfo_AllExtensions
        case .allHFSTypeCodes:
            return kAudioFileGlobalInfo_AllHFSTypeCodes
        case .allUTIs:
            return kAudioFileGlobalInfo_AllUTIs
        case .allMIMETypes:
            return kAudioFileGlobalInfo_AllMIMETypes
        case .extensionsForType:
            return kAudioFileGlobalInfo_ExtensionsForType
        case .hfsTypeCodesForType:
            return kAudioFileGlobalInfo_HFSTypeCodesForType
        case .utisForType:
            return kAudioFileGlobalInfo_UTIsForType
        case .mimeTypesForType:
            return kAudioFileGlobalInfo_MIMETypesForType
        case .typesForMIMEType:
            return kAudioFileGlobalInfo_TypesForMIMEType
        case .typesForUTI:
            return kAudioFileGlobalInfo_TypesForUTI
        case .typesForHFSTypeCode:
            return kAudioFileGlobalInfo_TypesForHFSTypeCode
        case .typesForExtension:
            return kAudioFileGlobalInfo_TypesForExtension
        }
    }

    public var fourCharCodeString: String {
        return AVHelper.fourCharCodeString(for: id)
    }

}
