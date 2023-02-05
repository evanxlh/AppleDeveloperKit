//
//  MainBundle.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation

/// Main bundle information, extracted values from main bundle infoDictionary.
public struct MainBundle {
    
    public static let bundle = AppleBundle(Bundle.main)
    
    /// CFBundleIdentifier
    public static var bundleID: String? {
        return bundle.bundleID
    }
    
    /// CFBundleExecutable
    public static var executableName: String? {
        return bundle.executableName
    }
    
    /// CFBundleName
    public static var name: String? {
        return bundle.name
    }
    
    /// CFBundleDisplayName
    public static var displayName: String? {
        return bundle.displayName
    }
    
    /// CFBundleShortVersionString
    public static var shortVersion: String? {
        return bundle.shortVersion
    }
    
    /// CFBundleVersion
    public static var buildNumber: String? {
        return bundle.buildNumber
    }
    
    /// CFBundleShortVersionString + CFBundleVersion
    public static var fullVersion: String? {
        return bundle.fullVersion
    }
    
    /// Get the value by key from main bundle infoDictionary
    public static func value<T>(forKey key: String) -> T? {
        return bundle.value(forKey: key)
    }
}
