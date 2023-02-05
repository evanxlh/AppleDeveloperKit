//
//  DispatchQueue+ADK.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation

public extension DispatchQueue {
    
    /// A boolean value indicating whether the current running dispatch queue is main.
    static var isMain: Bool {
        return Thread.isMainThread
    }
    
    /// A boolean value indicating whether the given dispatch queue is the current
    /// running dispatch queue.
    static func isCurrent(_ queue: DispatchQueue) -> Bool {
        let key = DispatchSpecificKey<UInt32>()
        queue.setSpecific(key: key, value: arc4random())
        defer { queue.setSpecific(key: key, value: nil) }
        
        return DispatchQueue.getSpecific(key: key) != nil
    }
    
    /// Running block on the queue synchronously without deadlock.
    @discardableResult
    func syncWithoutDeadlock<T>(_ block: @autoclosure () -> T) -> T {
        if DispatchQueue.isCurrent(self) {
            return block()
        } else {
            return sync { block() }
        }
    }
    
    /// If the queue is the current, just run block directly, or async on the queue.
    func asyncIfNeed(_ block: @escaping () -> Void) {
        if DispatchQueue.isCurrent(self) {
            block()
        } else {
            async { block() }
        }
    }
    
}
