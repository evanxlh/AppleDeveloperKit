//
//  AnyDispatchSource.swift
//  AppleDeveloperKitTests
//
//  Created by Evan Xie on 2023/2/17.
//

import Foundation

/// A wrapper for DispatchSource, just safe to call activate/cancel/suspend/resume of DispatchSource.
public final class AnyDispatchSource {

    public enum State: Int {
        case idle
        case running
        case paused
    }

    public var state: State {
        return lock.sync({ self._state })
    }

    public init(_ source: DispatchSourceProtocol) {
        self.source = source
    }

    public func start() {
        guard state == .idle, !source.isCancelled else {
            return
        }
        source.activate()
        _state = .running
    }

    public func cancel() {
        switch state {
        case .running:
            source.cancel()
            _state = .idle
        case .paused:
            source.resume()
            source.cancel()
            _state = .idle
        default:
            break
        }
    }

    /// Calls to `pause()` must be balanced with calls to `resume()`.
    /// - See [DispatchObject Suspend](https://developer.apple.com/documentation/dispatch/dispatchobject/1452801-suspend)
    public func pause() {
        guard state == .running else { return }
        source.suspend()
        _state = .paused
    }

    public func resume() {
        guard state == .paused else { return }
        source.resume()
        _state = .running
    }

    private let source: DispatchSourceProtocol
    private let lock = MutexLock()
    private var _state: State = .idle
}
