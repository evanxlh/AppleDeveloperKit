//
//  DispatchQueue+ADK.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation

extension DispatchQueue: AppleDeveloperKitCompatible {}

public extension AppleDeveloperKitWrapper where Base == DispatchQueue {
    
    /// A boolean value indicating whether the current running dispatch queue is main.
    var isMain: Bool {
        return Thread.isMainThread
    }
    
    /// A boolean value indicating whether the queue is the current
    /// running dispatch queue.
    var isCurrent: Bool {
        let key = DispatchSpecificKey<UInt32>()
        base.setSpecific(key: key, value: arc4random())
        defer { base.setSpecific(key: key, value: nil) }
        
        return DispatchQueue.getSpecific(key: key) != nil
    }
    
    /// Running block on the queue synchronously without deadlock.
    @discardableResult
    func sync<T>(_ block: @autoclosure () -> T) -> T {
        if isCurrent {
            return block()
        } else {
            return base.sync { block() }
        }
    }
    
    /// If the queue is the current, just run block directly, or async on the queue.
    func async(_ block: @escaping () -> Void) {
        if isCurrent {
            block()
        } else {
            base.async { block() }
        }
    }
    
}

