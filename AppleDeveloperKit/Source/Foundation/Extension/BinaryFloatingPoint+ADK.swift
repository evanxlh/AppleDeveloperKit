//
//  BinaryFloatingPoint+ADK.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/6.
//

import Foundation

/// 精度：保留几位小数位
///
/// - Note:
/// 具体能达到多少精度，要视浮点数类型来确定。
/// 比如在写这个扩展的时候, 在 Swift 中 Float 可以精确到 7 位小数, Double 能精确到 15 位小数。
///
/// 如果指定的精度小数位超出浮点数据类型的最大精度，最终结果也只能采用浮点数据类型
/// 本身能支持的最大精度来计算。
public enum FloatPointPrecision {
    case decimalPlaces(Int)
    
    public var numberOfDecimalPlaces: Int {
        switch self {
        case .decimalPlaces(let count):
            return count
        }
    }
}


/// 浮点数(如 Float, Dobule)扩展方法
public extension BinaryFloatingPoint {
    
    /// 选用给定的`rule`和`precision`对浮点数进行舍入。
    func rounded(byRule rule: FloatingPointRoundingRule, precision: FloatPointPrecision) -> Self {
        let precision = Self.init(pow(10.0, Float(precision.numberOfDecimalPlaces)))
        let value = self * precision
        return value.rounded(rule) / precision
    }
    
    /// 在给定的精度范围内，比较两个浮点数是否相等。
    func isEqual(to other: Self, precision: FloatPointPrecision) -> Bool {
        let diff = abs(self - other)
        let p = 1.0 / Self.init(pow(10.0, Float(precision.numberOfDecimalPlaces)))
        return diff < p
    }
    
    /// 是否比 `other` 小
    func isLessThan(other: Self, precision: FloatPointPrecision) -> Bool {
        let diff = self - other
        let p = 1.0 / Self.init(pow(10.0, Float(precision.numberOfDecimalPlaces)))
        return diff < 0 && abs(diff) >= p
    }
    
    /// 是否比 `other` 大
    func isGreaterThan(other: Self, precision: FloatPointPrecision) -> Bool {
        let diff = self - other
        let p = 1.0 / Self.init(pow(10.0, Float(precision.numberOfDecimalPlaces)))
        return diff > 0 && diff >= p
    }
    
}
