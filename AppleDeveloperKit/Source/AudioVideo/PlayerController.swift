//
//  PlayerController.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/6.
//

import AVFoundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public extension AVAssetTrack {
    
    /// The duration of one frame lasts.
    var videoFrameDuration: CMTime {
        if minFrameDuration.isValid {
            return minFrameDuration
        } else if nominalFrameRate > 0 {
            return CMTime(seconds: 1.0 / Double(nominalFrameRate), preferredTimescale: 600)
        } else {
            return CMTime(seconds: 1.0 / 30.0, preferredTimescale: 600)
        }
    }
    
}

/// PlayerController can play and seek very smoothly and precisely.
public class PlayerController: NSObject {
    fileprivate var timeObserver: Any?
    fileprivate var playToEndObserver: Any?
    fileprivate var shouldResumePlaying: Bool = false
    fileprivate var seekTimeInProgress: CMTime?
    fileprivate var seekTimeInWaiting: CMTime?
    fileprivate var _playerStatus: PlayerStatus = .unknown
    
    /// 播放进度刷新频率, 默认每秒 30 次
    public var progressRefreshRate: Int = 30
    
    /// 监听器: 播放进度更新
    public var progressCallback: ((_ time: CMTime, _ location: Double) -> Void)?
    
    /// 监听器: 播放器状态变化
    public var statusCallback: ((PlayerStatus) -> Void)?
    
    /// 监听器: 播放到末尾
    public var playToEndCallback: (() -> Void)?
    
    public let player: AVPlayer
    
    public override init() {
        player = AVPlayer()
        player.actionAtItemEnd = .pause
        super.init()
        addAppStateObserver()
        listenPlayerCommonEvents()
    }
    
    public convenience init(asset: AVAsset) {
        self.init()
        loadAsset(asset)
    }
    
    public convenience init(assetURL: URL) {
        let asset = AVURLAsset(url: assetURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        self.init(asset: asset)
    }
    
    deinit {
        unlistenAllEvents()
        NotificationCenter.default.removeObserver(self)
        player.replaceCurrentItem(with: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(AVPlayer.status),
           let value = change?[.newKey] as? Int,
           let status = AVPlayer.Status(rawValue: value)
        {
            handlePlayerStatusChange(mapUnderlyingStatus(status))
            return
        }
        
        if keyPath == #keyPath(AVPlayer.timeControlStatus) {
            handlePlayerStatusChange(mapUnderlyingStatus(player.timeControlStatus))
            return
        }
        
        if keyPath == #keyPath(AVPlayer.currentItem) {
            unlistenPlayerItemEvents()
            unlistenPlayingProgress()
            
            if let newItem = change?[.newKey] as? AVPlayerItem {
                listenPlayerItemEvents(newItem)
                listenPlayingProgressIfNeed()
            }
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}

//MARK: - Asset

public extension PlayerController {
    
    var currentAsset: AVAsset? {
        return player.currentItem?.asset
    }
    
    var currentPlayItem: AVPlayerItem? {
        return player.currentItem
    }
    
    var currentVideoTracks: [AVAssetTrack] {
        return currentAsset?.tracks(withMediaType: .video) ?? []
    }
    
    var currentVideoFramerate: Double {
        return Double(currentVideoTracks.first?.nominalFrameRate ?? 30)
    }
    
    func loadAssetURL(_ assetURL: URL?) {
        var asset: AVAsset? = nil
        if let url = assetURL {
            asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        }
        loadAsset(asset)
    }
    
    func loadAsset(_ asset: AVAsset?) {
        player.currentItem?.cancelPendingSeeks()
        seekTimeInWaiting = nil
        seekTimeInProgress = nil
        
        if asset != nil {
            let playerItem = AVPlayerItem(asset: asset!, automaticallyLoadedAssetKeys: ["duration"])
            player.replaceCurrentItem(with: playerItem)
        } else {
            player.replaceCurrentItem(with: nil)
        }
    }
    
}

//MARK: - Player Status

public extension PlayerController {
    
    enum PlayerStatus: Int {
        case unknown
        case readyToPlay
        case playing
        case paused
        case failToLoad
    }
    
    /// If still not obtained the video duration, return CMTime.invalid.
    var duration: CMTime {
        return player.currentItem?.asset.duration ?? .invalid
    }
    
    var currentPlayTime: CMTime {
        return player.currentItem?.currentTime() ?? .zero
    }
    
    var currentPlayLocation: Double {
        if duration.isValid { return 0.0 }
        if duration.seconds == 0.0 { return 1.0 }
        return currentPlayTime.seconds / duration.seconds
    }
    
    var playerStatus: PlayerStatus {
        return _playerStatus
    }
    
    var isPlaying: Bool {
        return _playerStatus == .playing
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
}

//MARK: - Seek APIs

public extension PlayerController {
    
    enum SeekDirection: Int {
        case forward
        case backward
    }
    
    func seekToBegin() {
        seekToTime(.zero)
    }
    
    func seekToEnd() {
        guard !duration.isValid else { return }
        seekToEnd()
    }
    
    func seekToTime(_ time: CMTime) {
        seekTimeInWaiting = time
        guard player.status == .readyToPlay else { return }
        guard seekTimeInProgress == nil else { return }
        
        doActualSeek(time)
    }
    
    /// `location` 取值范围 [0.0, 1.0]
    func seekToLocation(_ location: Double) {
        let duration = duration
        guard !duration.isValid else { return }
        
        let corrected = min(1.0, max(0.0, location))
        seekToSeconds(duration.seconds * corrected)
    }
    
    func seekToSeconds(_ seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        seekToTime(time)
    }
    
    /// 逐帧或每隔几帧 seek
    func seekByFrame(count: Int = 1, direction: SeekDirection) {
        guard let videoTrack = currentVideoTracks.first else { return }
        
        let oneFrameDuration = videoTrack.videoFrameDuration
        let framesTime = CMTimeMultiply(oneFrameDuration, multiplier: Int32(count))
        if direction == .forward {
            seekToTime(currentPlayTime + framesTime)
        } else {
            seekToTime(currentPlayTime - framesTime)
        }
    }
    
}

//MARK: - Private Functions

fileprivate extension PlayerController {
    
    func addAppStateObserver() {
        let center = NotificationCenter.default
        
#if os(iOS)
        center.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
#elseif os(macOS)
        center.addObserver(self, selector: #selector(appWillResignActive), name: NSApplication.willResignActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(appDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
#endif
        
    }
    
    @objc func appWillResignActive() {
        if player.timeControlStatus == .playing {
            shouldResumePlaying = true
            player.pause()
        }
    }
    
    @objc func appDidBecomeActive() {
        if shouldResumePlaying {
            player.play()
        }
    }
    
    func listenPlayerCommonEvents() {
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.old, .new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: .new, context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: .new, context: nil)
    }
    
    func unlistenPlayerCommonEvents() {
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), context: nil)
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status), context: nil)
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), context: nil)
        
    }
    
    func listenPlayingProgressIfNeed() {
        guard progressCallback != nil else { return }
        
        let oneFrameSeconds = 1.0 / currentVideoFramerate
        let interval = CMTime(seconds: oneFrameSeconds, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] currentTime in
            guard let `self` = self else { return }
            guard self.playerStatus == .playing else { return }
            self.progressCallback?(currentTime, currentTime.seconds / self.duration.seconds)
        }
    }
    
    func unlistenPlayingProgress() {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
        }
        timeObserver = nil
    }
    
    func listenPlayerItemEvents(_ playerItem: AVPlayerItem) {
        let center = NotificationCenter.default
        playToEndObserver = center.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            self?.playToEndCallback?()
        }
    }
    
    func unlistenPlayerItemEvents() {
        guard let observer = playToEndObserver else { return }
        NotificationCenter.default.removeObserver(observer)
        playToEndObserver = nil
    }
    
    func unlistenAllEvents() {
        unlistenPlayerCommonEvents()
        unlistenPlayerItemEvents()
        unlistenPlayingProgress()
    }
    
    func handlePlayerStatusChange(_ newStatus: PlayerStatus) {
        _playerStatus = newStatus
        statusCallback?(_playerStatus)
    }
    
    func doActualSeek(_ time: CMTime) {
        seekTimeInProgress = time
        seekTimeInWaiting = nil
        
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let `self` = self else { return }
            if let nextSeekTime = self.seekTimeInWaiting, nextSeekTime != time {
                self.doActualSeek(nextSeekTime)
            } else {
                self.seekTimeInWaiting = nil
                self.seekTimeInProgress = nil
            }
        }
    }
    
    func mapUnderlyingStatus(_ status: AVPlayer.Status) -> PlayerStatus {
        switch status {
        case .failed:
            return .failToLoad
        case .readyToPlay:
            return .readyToPlay
        default:
            return .failToLoad
        }
    }
    
    func mapUnderlyingStatus(_ status: AVPlayer.TimeControlStatus) -> PlayerStatus {
        switch status {
        case .playing:
            return .playing
        case .paused:
            return .paused
        case .waitingToPlayAtSpecifiedRate:
            return .playing
        @unknown default:
            return .paused
        }
    }
    
}

