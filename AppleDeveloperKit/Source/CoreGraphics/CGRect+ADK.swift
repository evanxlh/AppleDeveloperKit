//
//  CGRect+ADK.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation
import CoreGraphics

extension CGRect: AppleDeveloperKitCompatible {}

public extension AppleDeveloperKitWrapper where Base == CGRect {
    
    func scaled(by scale: CGFloat) -> CGRect {
        let origin = CGPoint(x: base.origin.x * scale, y: base.origin.y * scale)
        let size = CGSize(width: base.width * scale, height: base.height * scale)
        return CGRect(origin: origin, size: size)
    }
}
