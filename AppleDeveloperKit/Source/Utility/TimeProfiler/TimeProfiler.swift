//
//  TimeProfiler.swift
//  AppleDeveloperKit
//
//  Created by WS on 2023/2/6.
//

import Foundation

/// TimeProfiler is designed for measuring time cost of your codes running.
///
/// Two way to use time profiler:
/// - Use `begin`/`end` in pairs
/// - Use `measure` directly
///
public struct TimeProfiler {
    
    private var beginTimestamp: CFAbsoluteTime
    private var endTimestamp: CFAbsoluteTime
    private var tag: String?
    
    /// The total time cost of your codes running.
    public var timeCost: CFAbsoluteTime {
        return endTimestamp - beginTimestamp
    }
    
    /// Check time profiler is measuring or not.
    public private(set) var isMeasuring: Bool
    
    public init() {
        beginTimestamp = 0
        endTimestamp = 0
        isMeasuring = false
    }
    
    /// Start measuring time, and keep the begin timestamp
    public mutating func begin(_ tagName: String? = nil) {
        isMeasuring = true
        tag = tagName
        beginTimestamp = CFAbsoluteTimeGetCurrent()
        endTimestamp = beginTimestamp
    }
    
    /// End measure time cost, and return time cost.
    @discardableResult
    public mutating func end() -> CFAbsoluteTime {
        endTimestamp = CFAbsoluteTimeGetCurrent()
        isMeasuring = false
        return endTimestamp - beginTimestamp
    }
    
    private func printTimeCost() {
        if let tag = self.tag {
            print("[TimeProfiler] \(tag) time cost: \(timeCost)")
        } else {
            print("[TimeProfiler] time cost: \(timeCost)")
        }
    }
}

public extension TimeProfiler {
    
    /// Measuring the time cost of `block` running.
    /// - Parameters:
    ///   - block: The code you want to measure. It must run sequentially, can't be async.
    ///   - tagName: A tag for your measure block, just for a debug print.
    @discardableResult
    static func measure<T>(tagName: String? = nil, block: () -> T) -> T {
        
        var profiler = TimeProfiler()
        profiler.begin(tagName)
        defer {
            profiler.end()
            profiler.printTimeCost()
        }
        
        return block()
    }
    
    /// Measuring the time cost of `block` running.
    /// - Parameters:
    ///   - block: The code you want to measure. It must run sequentially, can't be async.
    ///   - tagName: A tag for your measure block, just for a debug print.
    ///   - resultCallback: The time cost result callback.
    ///
    @discardableResult
    static func measure<T>(tagName: String? = nil, block: () -> T, resultCallback: @escaping (CFAbsoluteTime) -> Void) -> T {
        
        var profiler = TimeProfiler()
        profiler.begin(tagName)
        
        defer {
            profiler.end()
            resultCallback(profiler.timeCost)
        }
        
        return block()
    }
}
