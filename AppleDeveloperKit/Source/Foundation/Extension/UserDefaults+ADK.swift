//
//  UserDefaults+ADK.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/6.
//

import Foundation

public extension UserDefaults {
    
    static func bool(forKey key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    static func integer(forKey key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    static func float(forKey key: String) -> Float {
        return UserDefaults.standard.float(forKey: key)
    }
    
    static func double(forKey key: String) -> Double {
        return UserDefaults.standard.double(forKey: key)
    }
    
    static subscript(key: String) -> Any? {
        get { return Self.standard[key] }
        set { Self.standard[key] = newValue }
    }
    
    subscript(key: String) -> Any? {
        get { return object(forKey: key) }
        set { newValue == nil ? removeObject(forKey: key) : set(newValue, forKey: key) }
    }
}
