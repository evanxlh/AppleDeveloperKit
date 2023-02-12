//
//  MultiTimeProfiler.swift
//  AppleDeveloperKit
//
//  Created by WS on 2023/2/6.
//

import Foundation

/// 测试多项任务的各自时间消耗，以前总时间消耗
public final class MultipleTimeProfiler {
    
    public struct MeasurementResultItem {
        var tag: String
        var timeCost: CFAbsoluteTime
    }

    private var lock = MutexLock()
    private var _resultItems = [MeasurementResultItem]()
    
    public var resultItems: [MeasurementResultItem] {
        return lock.sync({ _resultItems })
    }
    
    public let name: String
    
    init(name: String) {
        self.name = name
    }
    
    @discardableResult
    public func measure<T>(tagName: String, block: () -> T, resultCallback: ((TimeInterval) -> Void)? = nil) -> T {
        TimeProfiler.measure(tagName: tagName, block: block) { [unowned self] timeCost in
            self.lock.sync {
                let item = MeasurementResultItem(tag: tagName, timeCost: timeCost)
                self._resultItems.append(item)
            }
            resultCallback?(timeCost)
        }
    }
    
    /// Return final report string
    func reports() -> String {
        var reports: String = "MultipleTimeProfiler[\(name)] Timecost Report(millisecond): \n"
        let items = resultItems
        var totalTimeCost: CFAbsoluteTime = 0.0
        
        for item in items {
            totalTimeCost += item.timeCost
            reports.append("\t\(item.tag): \(Int(item.timeCost * 1000))ms\n")
        }
        reports.append("\n\tTotal timecost: \(Int(totalTimeCost * 1000))ms\n")
        return reports
    }
    
    func clear() {
        _resultItems.removeAll()
    }

}
