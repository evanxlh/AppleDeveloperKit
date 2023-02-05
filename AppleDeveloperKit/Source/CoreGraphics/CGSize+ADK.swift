//
//  CGSize+ADK.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation
import CoreGraphics

public enum ResizeMode: Int {
    case none
    case aspectFit
    case aspectFill
}

extension CGSize: AppleDeveloperKitCompatible {}

public extension AppleDeveloperKitWrapper where Base == CGSize {
    
    /// 宽高比
    var aspectRatio: CGFloat {
        return base.height == 0.0 ? 1.0 : base.width / base.height
    }
    
    /// 高宽比
    var aspectRatioReversed: CGFloat {
        return base.width == 0.0 ? 1.0 : base.height / base.width
    }
    
    /// 保持比例去适应给定的 size
    func aspectFit(in size: CGSize) -> CGSize {
        let aspectWidth = size.height * aspectRatio
        let aspectHeight = size.width * aspectRatioReversed
        
        return aspectWidth > size.width ?
        CGSize(width: size.width, height: aspectHeight) :
        CGSize(width: aspectWidth, height: size.height)
    }
    
    /// 保持比例去填充给定的 size
    func aspectFill(in size: CGSize) -> CGSize {
        let aspectWidth = size.height * aspectRatio
        let aspectHeight = size.width * aspectRatioReversed
        
        return aspectWidth < size.width ?
        CGSize(width: size.width, height: aspectHeight) :
        CGSize(width: aspectWidth, height: size.height)
    }
    
    func resize(to size: CGSize, mode: ResizeMode) -> CGSize {
        switch mode {
        case .aspectFit:
            return aspectFit(in: size)
        case .aspectFill:
            return aspectFill(in: size)
        case .none:
            return size
        }
    }
    
    /// 使用指定 size 和 锚点来裁剪
    func croppedRect(with size: CGSize, anchor: CGPoint) -> CGRect {
        let normalizedAnchor = anchor.adk.normalized
        let x = normalizedAnchor.x * (base.width - size.width)
        let y = normalizedAnchor.y * (base.height - size.height)
        let cropped = CGRect(x: x, y: y, width: size.width, height: size.height)
        return CGRect(origin: .zero, size: base).intersection(cropped)
    }
    
}

public extension CGSize {
    
    func scaled(by scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
}

