//
//  DispatchTimer.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation

/// Thread-safe dispatch timer, can be used repeatedly.
/// - Supports pause and resume.
public class DispatchTimer {
    
    public typealias FireClosure = (_ timer: DispatchTimer, _ fireInfo: FireInfo) -> Void
    
    public struct FireInfo {
        /// The timer fires every `interval` seconds
        public var interval: TimeInterval
        
        /// How many times has the time fired.
        public var firedTimes: UInt
    }
    
    public enum RepeatMode {
        case always
        case count(UInt)
    }
    
    public var isRunning: Bool {
        return timer?.state == .running
    }
    
    public var state: AnyDispatchSource.State {
        return timer?.state ?? .idle
    }

    public var cancelledCallback: (() -> Void)? = nil
    
    public init(flags: DispatchSource.TimerFlags = [.strict], queue: DispatchQueue = .main) {
        self.flags = flags
        self.queue = queue
    }
    
    
    /// Schedule timer immediately.
    /// - Parameters:
    ///   - interval: Timer fires every `interval` seconds
    ///   - repeatMode: Timer only fires once by default, you can set repeat count.
    ///   - fireClosure: Timer fire callback, do what you want.
    public func schedule(withInterval interval: TimeInterval, repeatMode: RepeatMode = .count(1), fireClosure: @escaping FireClosure) {
        guard state == .idle else {
            print("DispatchTimer is running now")
            return
        }

        let timer = DispatchSource.makeTimerSource(flags: flags, queue: queue)
        timer.setEventHandler { [weak self] in
            guard let `self` = self else { return }
            self.repeatedCount = self.repeatedCount.addingReportingOverflow(1).partialValue
            fireClosure(self, FireInfo(interval: interval, firedTimes: self.repeatedCount))
            
            guard case .count(let count) = repeatMode else { return }
            if self.repeatedCount >= count {
                self.cancel()
            }
        }
        timer.setCancelHandler { [weak self] in
            self?.cancelledCallback?()
        }
        timer.schedule(deadline: .now() + interval, repeating: interval)
        self.timer = AnyDispatchSource(timer)
        self.timer?.start()
    }
    
    /// Timer.suspend is not accurate for timing. The best way is to remeber start/pause timestamp,
    ///  then computer how long time remaing, and start another timer.
    ///
    /// See [DispatchObject Suspend](https://developer.apple.com/documentation/dispatch/dispatchobject/1452801-suspend)
    public func pause() {
        self.timer?.pause()
    }
    
    public func resume() {
        self.timer?.resume()
    }
    
    public func cancel() {
        self.timer?.cancel()
    }
    
    private var queue: DispatchQueue
    private var flags: DispatchSource.TimerFlags
    public var timer: AnyDispatchSource?
    private var repeatedCount: UInt = 0
}
