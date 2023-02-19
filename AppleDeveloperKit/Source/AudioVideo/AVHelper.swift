//
//  AVHelper.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

import Foundation
import CoreAudio

public enum AVHelper {

    public static func fourCharCodeString(for fourCharCode: FourCharCode) -> String {
        let utf16 = [
            UInt16((fourCharCode >> 24) & 0xFF),
            UInt16((fourCharCode >> 16) & 0xFF),
            UInt16((fourCharCode >> 8) & 0xFF),
            UInt16((fourCharCode & 0xFF))
        ]
        return String(utf16CodeUnits: utf16, count: 4)
    }

    public static func debugDescriptionForAudioFormatFlags(_ flags: AudioFormatFlags) -> String {
        let isBigEndian = (flags & kAudioFormatFlagIsBigEndian) != 0
        let isInterleaved = (flags & kAudioFormatFlagIsNonInterleaved) == 0
        let isPacked = (flags & kAudioFormatFlagIsPacked) != 0
        let isFloat = (flags & kAudioFormatFlagIsFloat) != 0
        let isSignedInt = (flags & kAudioFormatFlagIsSignedInteger) != 0

        return "AudioFormatFlags: [\n\tIsBigEndia: \(isBigEndian ? "true" : "false"))\n\tIsInterleaved: \(isInterleaved ? "true" : "false")\n\tIsPacked: \(isPacked ? "true" : "false")\n\tIsFloat: \(isFloat ? "true" : "false")\n\tIsSignedInt: \(isSignedInt ? "true" : "false")\n]"
    }

}

extension AudioStreamBasicDescription: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "AudioStreamBasicDescription[\n\tmSampleRate: \(mSampleRate)\n\tmFormatID: \(AVHelper.fourCharCodeString(for: mFormatID))\n\tmFormatFlags: \(AVHelper.debugDescriptionForAudioFormatFlags(mFormatFlags))\n\tmBytesPerPacket: \(mBytesPerPacket)\n\tmFramesPerPacket: \(mFramesPerPacket)\n\tmBytesPerFrame: \(mBytesPerFrame)\n\t mChannelsPerFrame: \(mChannelsPerFrame)\n\tmBitsPerChannel: \(mBitsPerChannel)\n\tmReserved: \(mReserved)\n]"
    }
}
