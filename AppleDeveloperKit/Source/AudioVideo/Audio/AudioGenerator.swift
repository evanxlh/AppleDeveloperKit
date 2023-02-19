//
//  AudioGenerator.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

import Foundation
import CoreAudio
import AudioToolbox

public enum AudioType: Int {
    case squareWave
    case sawWave
    case sinWave
    case randomWave
}

public struct AudioConfiguration {
    public var type: AudioType
    public var frequency: Float64 // HZ
    public var sampleRate: Float64

    public init(type: AudioType, frequency: Float64, sampleRate: Float64) {
        self.type = type
        self.frequency = frequency
        self.sampleRate = sampleRate
    }
}

public protocol AudioGeneratorDelegate: NSObjectProtocol {
    func audioGeneratorDidEncounterError(_ error: AudioFileError)
    func udioGeneratorDidFinish(_ audioFileURL: URL)
}

public class AudioGenerator {
    fileprivate var isStopped: Bool = true
    fileprivate var workingQueue: DispatchQueue

    //MARK: - Public

    public weak var delegate: AudioGeneratorDelegate?

    public init() {
        workingQueue = DispatchQueue(label: "AVToolkit.AudioGeneratorQueue")
    }

    public func start(configuration: AudioConfiguration, outputFileURL: URL? = nil) {
        guard isStopped else { return }

        workingQueue.async { [weak self] in
            guard let `self` = self else { return }

            let outputURL: URL
            if let url = outputFileURL {
                outputURL = url
            } else {
                outputURL = self.randomOutputAudioFileURL()
            }

            var asbd = self.defaultASBD(configuration)
            var fileID: AudioFileID?
            var status = AudioFileCreateWithURL(outputURL as CFURL, kAudioFileAIFFType, &asbd, AudioFileFlags.eraseFile, &fileID)
            guard status == noErr else {
                print(AudioFileError(status))
                self.triggerError(status)
                return
            }

            self.isStopped = false
            status = self.sampleWave(type: configuration.type, fileID: fileID!, configuration: configuration)
            guard status == noErr else {
                self.triggerError(status)
                return
            }

            status = AudioFileClose(fileID!)
            if status != noErr {
                print("Close audio file failed: \(AudioFileError(status))")
            }

            DispatchQueue.main.async { [weak self] in
                self?.delegate?.udioGeneratorDidFinish(outputURL)
            }
        }
    }

    public func stop() {
        self.isStopped = true
    }

}

fileprivate extension AudioGenerator {

    func sampleWave(type: AudioType, fileID: AudioFileID, configuration: AudioConfiguration) -> OSStatus {
        var sampleIndex: Int64 = 0
        var bytesToWrite: UInt32 = 2

        // Calculate how many samples are in a wavelength
        let waveLength = configuration.sampleRate / configuration.frequency
        let length = Int(waveLength)

        while !isStopped {
            var sample: Int16 = 0
            for index in 0..<length {
                sample = getSample(forWave: type, waveLength: waveLength, sampleIndexInWave: index)
                let status = AudioFileWriteBytes(fileID, false, sampleIndex * 2, &bytesToWrite, &sample)
                guard status == noErr else {
                    print("Write audio file bytes failed: \(AudioFileError(status))")
                    return status
                }
                sampleIndex += 1
            }
        }

        return noErr
    }

    func getSample(forWave type: AudioType, waveLength: Float64, sampleIndexInWave: Int) -> Int16 {
        switch type {
        case .squareWave:
            // Due to we want to generate square wave, so the first half of the wavelength, we use the maximum amplitude.
            // The rest of the wavelength, use the minimum amplitude
            if sampleIndexInWave < Int(waveLength * 0.5) {
                return Int16.max.bigEndian
            } else {
                return Int16.min.bigEndian
            }

        case .sawWave:
            let sample = Float64(sampleIndexInWave) / waveLength * Float64(Int16.max) * 2 - Float64(Int16.max)
            return Int16(sample).bigEndian

        case .sinWave:
            let sample = sin(2 * Float64.pi * Float64(sampleIndexInWave) / waveLength) * Float64(Int16.max)
            return  Int16(sample).bigEndian
        case .randomWave:
            let sample = arc4random() % UInt32(Int16.max)
            return Int16(sample).bigEndian
        }
    }

    func defaultASBD(_ configuration: AudioConfiguration) -> AudioStreamBasicDescription {
        return AudioStreamBasicDescription(
            mSampleRate: configuration.sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsPacked,
            mBytesPerPacket: 2,
            mFramesPerPacket: 1,
            mBytesPerFrame: 2,
            mChannelsPerFrame: 1,
            mBitsPerChannel: 16,
            mReserved: 0
        )
    }

    func randomOutputAudioFileURL() -> URL {
        let filenmae = "\(UUID().uuidString).aif"
        let path = (NSTemporaryDirectory() as NSString).appendingPathComponent(filenmae)
        return URL(fileURLWithPath: path)
    }

    func triggerError(_ errorCode: OSStatus) {
        let error = AudioFileError(errorCode)
        DispatchQueue.main.async {
            self.delegate?.audioGeneratorDidEncounterError(error)
        }
    }

}
