//
//  CameraPreviewView.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/12.
//

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif
import AVFoundation

open class CameraPreviewView: ADKView {
    
    #if canImport(UIKit)
    open override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    #endif
    
    public var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    #if os(iOS)
    public var isPreviewing: Bool {
        return previewLayer.isPreviewing
    }
    #endif
    
    public var videoGravity: AVLayerVideoGravity {
        get { return previewLayer.videoGravity }
        set { previewLayer.videoGravity = newValue }
    }
    
    public var session: AVCaptureSession? {
        get { return previewLayer.session }
        set { previewLayer.session = newValue }
    }
    
    #if canImport(AppKit)
    open override func makeBackingLayer() -> CALayer {
        return AVCaptureVideoPreviewLayer()
    }
    #endif
}
