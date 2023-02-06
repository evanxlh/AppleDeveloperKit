//
//  VideoCutter.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/6.
//

import AVFoundation

/// Trimming a single video.
///
/// For quick-time video, you can specify `Quality.lossless` to keep the original video quality,
/// and it's very fast to trim video without re-encoding.
@available(iOS 13.0, *)
public class VideoTrimmer {
    fileprivate let lock = NSLock()
    fileprivate var _status: Status = .idle
    fileprivate let exportSession: AVAssetExportSession
    fileprivate let videoAsset: AVAsset
    fileprivate let quality: Quality
    
    fileprivate lazy var outputURL: URL = {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).resolvingSymlinksInPath()
        return tempURL.appendingPathComponent("\(NSUUID().uuidString)_trimmed.mp4")
    }()
    
    public var currentStatus: Status {
        lock.lock()
        defer { lock.unlock() }
        return _status
    }
    
    /// The part of video which will be kept
    public var timeRange: CMTimeRange = .invalid
    
    public convenience init(videoURL: URL, exportQuality: Quality) throws {
        let asset: AVAsset
        if exportQuality == .lossless {
            asset = AVMutableMovie(url: videoURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        } else {
            asset = AVURLAsset(url: videoURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        }
        try self.init(asset: asset, exportQuality: exportQuality)
    }
    
    public init(asset: AVAsset, exportQuality: Quality) throws {
        
        if exportQuality == .lossless {
            guard asset.isKind(of: AVMutableMovie.self) else {
                throw CreationError.losslessTrimNotSupported
            }
        }
        
        guard let session = AVAssetExportSession(asset: asset, presetName: exportQuality.presetName) else {
            throw CreationError.losslessTrimNotSupported
        }
        
        videoAsset = asset
        quality = exportQuality
        exportSession = session
        exportSession.outputFileType = .mp4
        exportSession.outputURL = outputURL
    }
    
    public func startTrimming(onSuccess: @escaping (URL) -> Void, onFailure: @escaping (TrimingError) -> Void) {
        guard currentStatus != .exporting else {
            print("VideoTrimmer is still trimming")
            return
        }
        
        do {
            transitionStatus(to: .exporting)
            try setupFinalTimeRangeForExport()
        } catch {
            onFailure(error as! TrimingError)
            return
        }
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch self.exportSession.status {
                case .completed:
                    self.transitionStatus(to: .finished)
                    onSuccess(self.outputURL)
                case .cancelled:
                    self.transitionStatus(to: .idle)
                    onFailure(TrimingError.cancelled)
                case .failed:
                    self.transitionStatus(to: .error)
                    if let error = self.exportSession.error {
                        onFailure(TrimingError.underlyingError(error))
                    } else {
                        onFailure(TrimingError.unknownError)
                    }
                default:
                    break
                }
            }
        }
    }
    
    public func cancelTrimming() {
        guard currentStatus == .exporting else { return }
        exportSession.cancelExport()
        self.transitionStatus(to: .cancelled)
    }
    
}

public extension VideoTrimmer {
    
    enum CreationError: Error, CustomDebugStringConvertible {
        case losslessTrimNotSupported
        case failToCreateExportSession
        
        public var debugDescription: String {
            switch self {
            case .losslessTrimNotSupported:
                return "Lossless trim only support quick-time movie, like mov, m4v, mp4"
            case .failToCreateExportSession:
                return "Create export session from given video failed "
            }
        }
    }
    
    enum TrimingError: Error {
        /// Trimming video is cancelled by user
        case cancelled
        case canNotObtainVideoDuration
        case underlyingError(Swift.Error)
        case unknownError
    }
    
    enum Quality: Int {
        case low
        case medium
        case high
        case lossless
        
        fileprivate var presetName: String {
            return [AVAssetExportPresetLowQuality, AVAssetExportPresetMediumQuality, AVAssetExportPresetHighestQuality, AVAssetExportPresetPassthrough][rawValue]
        }
    }
    
    enum Status: Int {
        case idle
        case exporting
        case finished
        case error
        case cancelled
    }
    
}

@available(iOS 13.0, *)
fileprivate extension VideoTrimmer {
    
    func transitionStatus(to newStatus: Status) {
        _status = newStatus
    }
    
    func setupFinalTimeRangeForExport() throws {
        guard quality == .lossless else {
            exportSession.timeRange = timeRange
            return
        }
        
        // For lossless quality, asset must be AVMutableMovie
        let asset = videoAsset as! AVMutableMovie
        let duration = asset.duration
        if duration.isIndefinite {
            print("Video duration is not definite, that's to say the duration still not obtained")
            throw TrimingError.canNotObtainVideoDuration
        }
        
        let start = CMTime(value: 0, timescale: duration.timescale)
        if timeRange.start.value > start.value {
            let end = CMTime(value: timeRange.start.value - 1, timescale: timeRange.start.timescale)
            asset.removeTimeRange(CMTimeRange(start: start, end: end))
        }
        
        if duration.value > timeRange.end.value {
            let start = CMTime(value: timeRange.end.value + 1, timescale: timeRange.end.timescale)
            asset.removeTimeRange(CMTimeRange(start: start, end: duration))
        }
    }
    
}

