//
//  String+ADK.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/13.
//

import Foundation

public extension String {

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func localized(tableName: String? = nil, bundle: Bundle = Bundle.main, comment: String = "") -> String {
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, comment: comment)
    }

}

// MARK: - URL Path Operations

public extension String {

    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }

    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }

    var pathExtension: String {
        return (self as NSString).pathExtension
    }

    var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }

    func appendingPathComponent(_ pathComponent: String) -> String {
        return (self as NSString).appendingPathComponent(pathComponent)
    }

    func appendingPathExtension(_ ext: String) -> String? {
        return (self as NSString).appendingPathExtension(ext)
    }

    func toURL() -> URL? {
        return URL(string: self)
    }

    func toFileURL(isDirectory: Bool = false) -> URL {
        return URL(fileURLWithPath: self, isDirectory: isDirectory)
    }

}
