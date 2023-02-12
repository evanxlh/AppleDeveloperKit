//
//  VideoLayerView.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/12.
//

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif
import AVFoundation

/// 对 AVPlayerLayer 的封装，用于显示 AVPlayer 视频帧
open class VideoLayerView: ADKView {
    
    /// 监听视频是否可显示了, 回调会返回视频图像区域的实际区域: videoRect
    public var onReadyForDisplay: ((CGRect) -> Void)? = nil
    
    public var isReadyForDisplay: Bool {
        return playerLayer.isReadyForDisplay
    }
    
    public var videoRect: CGRect {
        return playerLayer.videoRect
    }
    
    public var videoGravity: AVLayerVideoGravity = .resizeAspect {
        didSet { playerLayer.videoGravity = videoGravity }
    }
    
    public var player: AVPlayer? {
        get { return playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    public var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    #if canImport(UIKit)
    public override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    #else
    open override func makeBackingLayer() -> CALayer {
        return AVPlayerLayer()
    }
    #endif
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        #if canImport(UIKit)
        backgroundColor = .clear
        #else
        wantsLayer = true
        #endif
        playerLayer.videoGravity = videoGravity
        playerLayer.backgroundColor = ADKColor.clear.cgColor
        addReadyForDisplayListener()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        addReadyForDisplayListener()
    }
    
    deinit {
        removeReadyForDisplayListener()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(AVPlayerLayer.isReadyForDisplay) else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if let isReady = change?[.newKey] as? Bool, isReady {
            onReadyForDisplay?(playerLayer.videoRect)
        }
    }
}

fileprivate extension VideoLayerView {
    
    func addReadyForDisplayListener() {
        playerLayer.addObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay), options: .new, context: nil)
    }
    
    func removeReadyForDisplayListener() {
        playerLayer.removeObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay), context: nil)
    }
    
}
