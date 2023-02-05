//
//  Version.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation

/// 版本(Software/hardware/resource version, and so on).
/// - 可直接使用 <, <=, ==, >=, > 等比较运算符进行判断
public struct Version {
    private var components = [Int]()
    
    public let versionString: String
    public let isValid: Bool
    
    public var major: Int {
        return components.first ?? 0
    }
    
    public var minor: Int {
        return components.count > 1 ? components[1] : 0
    }

    public init(_ versionString: String, separator: String = ".") {
        self.versionString = versionString
        let components = versionString.components(separatedBy: separator)
        let numbers = components.compactMap({ Int($0) })
        if numbers.count < components.count {
            self.isValid = false
            print("Version.swift: version string can only contains numbers: \(versionString)")
            return
        }
        if numbers.count < 2 {
            self.isValid = false
            print("Version.swift: version string should contain two parts(major version, minor version) at least")
            return
        }
        self.isValid = true
        self.components = numbers
    }
    
}

extension Version: Comparable {
    
    public static func < (lhs: Version, rhs: Version) -> Bool {
        let minCount = min(lhs.components.count, rhs.components.count)
        for index in 0..<minCount {
            if lhs.components[index] < rhs.components[index] { return true }
            if lhs.components[index] > rhs.components[index] { return false }
        }
        
        return lhs.components.count < rhs.components.count
    }
    
    public static func == (lhs: Version, rhs: Version) -> Bool {
        guard lhs.components.count == rhs.components.count else { return false }
        
        for index in 0..<lhs.components.count {
            if lhs.components[index] != rhs.components[index] { return false }
        }
        return true
    }
    
    public static func > (lhs: Version, rhs: Version) -> Bool {
        let minCount = min(lhs.components.count, rhs.components.count)
        for index in 0..<minCount {
            if lhs.components[index] > rhs.components[index] { return true }
            if lhs.components[index] < rhs.components[index] { return false }
        }
        
        return lhs.components.count > rhs.components.count
    }
    
}
