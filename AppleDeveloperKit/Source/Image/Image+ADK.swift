//
//  Image+ADK.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

public extension ADKImage {
    
    static func makeImage(from cgImage: CGImage, scale: CGFloat, referencedImage: ADKImage? = nil) -> ADKImage {
#if os(macOS)
        return ADKImage(cgImage: cgImage, size: .zero)
#else
        return ADKImage(cgImage: cgImage, scale: scale, orientation: referencedImage?.imageOrientation ?? .up)
#endif
    }
}

extension ADKImage: AppleDeveloperKitCompatible {}

public extension AppleDeveloperKitWrapper where Base == ADKImage {
    
    func resize(to size: CGSize) -> ADKImage {
#if os(macOS)
        let destImage = NSImage(size: size)
        destImage.lockFocus()
        
        let destRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        base.draw(in: destRect, from: .zero, operation: .copy, fraction: 1.0)
        destImage.unlockFocus()
        return destImage
#else
        let render = UIGraphicsImageRenderer(size: size)
        return render.image { context in
            base.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
#endif
    }
    
    func resize(to size: CGSize, mode: ResizeMode) -> ADKImage {
        let newSize = size.adk.resize(to: size, mode: mode)
        return resize(to: newSize)
    }
    
    func crop(to size: CGSize, anchor: CGPoint) -> ADKImage {
        guard let cgImage = self.cgImage else {
            assertionFailure("Cropping only limit to CGImage")
            return base
        }
        
        let croppingRect = self.size.adk.croppedRect(with: size, anchor: anchor)
        guard let image = cgImage.cropping(to: croppingRect) else {
            assertionFailure("Cropping image failed")
            return base
        }
        return ADKImage.makeImage(from: image, scale: self.scale, referencedImage: base)
    }
}

fileprivate extension AppleDeveloperKitWrapper where Base == ADKImage {

    var cgImage: CGImage? {
#if os(macOS)
        return base.cgImage(forProposedRect: nil, context: nil, hints: nil)
#else
        return base.cgImage
#endif
    }
    
    var size: CGSize {
#if os(macOS)
        return base.representations.reduce(.zero, { result, imageRep in
            let width = max(result.width, CGFloat(imageRep.pixelsWide))
            let height = max(result.height, CGFloat(imageRep.pixelsHigh))
            return CGSize(width: width, height: height)
        })
#else
        return base.size
#endif
    }
    
    var scale: CGFloat {
#if os(macOS)
        return 1.0
#else
        return base.scale
#endif
    }
    
}
