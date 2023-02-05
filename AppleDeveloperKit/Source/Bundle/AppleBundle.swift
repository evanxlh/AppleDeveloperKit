//
//  AppleBundle.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation

/// Bundle information, extracted values from bundle infoDictionary.
public struct AppleBundle {
    public let bundle: Bundle
    
    public init(_ bundle: Bundle) {
        self.bundle = bundle
    }
    
    public var info: [String: Any]? {
        return bundle.infoDictionary
    }
    
    /// CFBundleIdentifier
    public var bundleID: String? {
        return info?["CFBundleIdentifier"] as? String
    }
    
    /// CFBundleExecutable
    public var executableName: String? {
        return info?["CFBundleExecutable"] as? String
    }
    
    /// CFBundleName
    public var name: String? {
        return info?["CFBundleName"] as? String
    }
    
    /// CFBundleDisplayName
    public var displayName: String? {
        return (info?["CFBundleDisplayName"] as? String) ?? name
    }
    
    /// CFBundleShortVersionString
    public var shortVersion: String? {
        return info?["CFBundleShortVersionString"] as? String
    }
    
    /// CFBundleVersion
    public var buildNumber: String? {
        return info?["CFBundleVersion"] as? String
    }
    
    /// CFBundleShortVersionString + CFBundleVersion
    public var fullVersion: String? {
        if let version = shortVersion, let build = buildNumber {
            return "\(version)(\(build))"
        }
        if let version = shortVersion {
            return version
        }
        if let build = buildNumber {
            return build
        }
        return nil
    }
    
    /// Get the value by key from bundle infoDictionary
    public func value<T>(forKey key: String) -> T? {
        return info?[key] as? T
    }
    
}
