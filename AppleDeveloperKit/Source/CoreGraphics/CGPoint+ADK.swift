//
//  CGPoint+ADK.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation
import CoreGraphics

extension CGPoint: AppleDeveloperKitCompatible {}

public extension AppleDeveloperKitWrapper where Base == CGPoint {
    
    var normalized: CGPoint {
        return CGPoint(
            x: base.x.clamped(to: 0.0...1.0),
            y: base.y.clamped(to: 0.0...1.0)
        )
    }
    
}

