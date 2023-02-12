//
//  AppleDeveloperKit.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation

#if canImport(AppKit)
import AppKit
public typealias ADKImage = NSImage
public typealias ADKColor = NSColor
public typealias ADKView = NSView
#else
import UIKit
public typealias ADKImage = UIImage
public typealias ADKColor = UIColor
public typealias ADKView = UIView
#endif

/// AppleKit 中的类型包装器，用于提供扩展方法
public struct AppleDeveloperKitWrapper<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

public protocol AppleDeveloperKitCompatible {}

public extension AppleDeveloperKitCompatible {
    
    /// 命名空间，用于隔离 AppleKit 新增的扩展方法
    var adk: AppleDeveloperKitWrapper<Self> {
        return AppleDeveloperKitWrapper(self)
    }
}
