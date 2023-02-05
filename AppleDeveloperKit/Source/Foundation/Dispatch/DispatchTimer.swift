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
    
    public enum State: Int {
        case idle
        case running
        case paused
    }
    
    public enum RepeatMode {
        case always
        case count(UInt)
    }
    
    public var isRunning: Bool {
        lock.lock()
        defer { lock.unlock() }
        return timer != nil && !timer!.isCancelled
    }
    
    public var currentState: State {
        lock.lock()
        defer { lock.unlock() }
        return state
    }
    
    public init(flags: DispatchSource.TimerFlags = [.strict], queue: DispatchQueue = .main) {
        self.flags = flags
        self.queue = queue
        self.lock = NSLock()
    }
    
    
    /// Schedule timer immediately.
    /// - Parameters:
    ///   - interval: Timer fires every `interval` seconds
    ///   - repeatMode: Timer only fires once by default, you can set repeat count.
    ///   - fireClosure: Timer fire callback, do what you want.
    public func schedule(withInterval interval: TimeInterval, repeatMode: RepeatMode = .count(1), fireClosure: @escaping FireClosure) {
        guard currentState == .idle else {
            print("DispatchTimer is running now")
            return
        }
        
        state = .running
        
        timer = DispatchSource.makeTimerSource(flags: flags, queue: queue)
        timer?.schedule(deadline: .now() + interval, repeating: interval)
        timer?.setEventHandler { [weak self] in
            guard let `self` = self else { return }
            self.repeatedCount = self.repeatedCount.addingReportingOverflow(1).partialValue
            fireClosure(self, FireInfo(interval: interval, firedTimes: self.repeatedCount))
            
            guard case .count(let count) = repeatMode else { return }
            if self.repeatedCount >= count {
                self.invalidate()
            }
        }
        timer?.resume()
    }
    
    /// Timer.suspend is not accurate for timing. The best way is to remeber start/pause timestamp,
    ///  then computer how long time remaing, and start another timer.
    ///
    /// See [DispatchObject Suspend](https://developer.apple.com/documentation/dispatch/dispatchobject/1452801-suspend)
    public func pause() {
        if currentState == .running {
            state = .paused
            timer?.suspend()
        }
    }
    
    public func resume() {
        if currentState == .paused {
            state = .running
            timer?.resume()
        }
    }
    
    public func invalidate() {
        guard currentState != .idle else { return }
        timer?.cancel()
        timer = nil
        state = .idle
    }
    
    private var queue: DispatchQueue
    private var flags: DispatchSource.TimerFlags
    private var timer: DispatchSourceTimer?
    private let lock: NSLock
    private var repeatedCount: UInt = 0
    private var state: State = .idle
}
