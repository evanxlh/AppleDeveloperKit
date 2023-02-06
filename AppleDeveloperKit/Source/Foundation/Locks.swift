//
//  Locks.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation
import os.lock

// [Comparison between different locks.](https://www.vincents.cn/2017/03/14/ios-lock/)

public enum LockType {
    case nslock
    case mutexLock
    case unfairLock
    case semaphoreLock
}

/// In some cases, we want to test the performance lost by lock. So AnyLock can do this,
/// it can set the lock enable or disable,  the code structure is also not affected.
/// If not these cases, please use the detailed lock directly.
public final class AnyLock: Lockable {
    private var _lock: Lockable? = nil
    
    public init(type: LockType = .mutexLock, isEnabled: Bool = true) {
        guard isEnabled else { return }
        
        switch type {
        case .nslock:
            _lock = Lock()
        case .mutexLock:
            _lock = MutexLock()
        case .unfairLock:
            _lock = UnfairLock()
        case .semaphoreLock:
            _lock = SemaphoreLock()
        }
    }
    
    public func lock() {
        guard _lock != nil else { return }
        _lock?.lock()
    }
    
    public func unlock() {
        guard _lock != nil else { return }
        _lock?.unlock()
    }
}

/// A simple lock protocol.
///
/// - `lock/unlock` must be used in pairs.
/// - `sync` will lock then unlock automatically.
public protocol Lockable {
    func lock()
    func unlock()
    func sync<T>(_ clousure: () -> T) -> T
}

extension Lockable {
    public func sync<T>(_ clousure: () -> T) -> T {
        lock()
        defer { unlock() }
        return clousure()
    }
}


/**
 A `NSLock` wrapped lock. For more information, see [NSLock].
 
 [NSLock]:
 https://developer.apple.com/documentation/foundation/nslock
 
 - Warning: Lock and unlock should be called on the same thread.
 */
public final class Lock: Lockable {
    private let _lock: NSLock
    
    public init() {
        _lock = NSLock()
    }
    
    public func lock() {
        _lock.lock()
    }
    
    public func unlock() {
        _lock.unlock()
    }
}

/**
 A `pthread_mutex_t` wrapped lock. For more information, see [pthread_mutex_lock].
 
 [pthread_mutex_lock]:
 https://manpages.debian.org/stretch/glibc-doc/pthread_mutex_lock.3.en.html
 
 - Warning: Lock and unlock should be called on the same thread.
 */
public final class MutexLock: Lockable {
    private var _lock: pthread_mutex_t
    
    deinit {
        pthread_mutex_destroy(&_lock)
    }
    
    public init() {
        _lock = pthread_mutex_t()
        pthread_mutex_init(&_lock, nil)
    }
    
    public func lock() {
        pthread_mutex_lock(&_lock)
    }
    
    public func unlock() {
        pthread_mutex_unlock(&_lock)
    }
}

/**
 A `os_unfair_lock_lock` wrapped lock. For more information, see [os_unfair_lock_lock].
 
 [os_unfair_lock_lock]:
 https://developer.apple.com/documentation/os/1646466-os_unfair_lock_lock?language=objc
 
 - Warning: Lock and unlock should be called on the same thread.
 */
public final class UnfairLock: Lockable {
    private var _lock: os_unfair_lock
    
    public init() {
        _lock = os_unfair_lock()
    }
    
    public func lock() {
        os_unfair_lock_lock(&_lock)
    }
    
    public func unlock() {
        os_unfair_lock_unlock(&_lock)
    }
}

/**
 A 'DispatchSemaphore' wrapped locker. `SemaphoreLock` is not a real locker,
 but we can use it as a lock by specifying the value of semaphore as one.
 */
public final class SemaphoreLock: Lockable {
    private let _lock: DispatchSemaphore
    
    public init() {
        _lock = DispatchSemaphore(value: 1)
    }
    
    public func lock() {
        _lock.wait()
    }
    
    public func unlock() {
        _lock.signal()
    }
}
