//
//  NSWindow+Info.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/12.
//

#if os(macOS)

import AppKit
import CoreGraphics

/**
 A window dictionry example:
 
 {
 kCGWindowAlpha = 1;
 kCGWindowBounds =     {
 Height = 656;
 Width = 1350;
 X = 296;
 Y = 203;
 };
 kCGWindowIsOnscreen = 1;
 kCGWindowLayer = 0;
 kCGWindowMemoryUsage = 1232;
 kCGWindowNumber = 151;
 kCGWindowOwnerName = Notes;
 kCGWindowOwnerPID = 796;
 kCGWindowSharingState = 0;
 kCGWindowStoreType = 1;
 }
 */
public struct WindowInfo: CustomDebugStringConvertible {
    
    public var id: Int = 0
    
    /// Back to font: the more larger value, the more front on the screen.
    /// - Some windows may have the same windowLayer
    /// - kCGWindowLayer == 0, indicates that it's the window of your installed applications,
    /// usually not the system applications.
    public var layer: Int = Int.min
    
    /// Front to back: the more smaller value, the more front on the screen
    /// - Each window has different window order.
    public var order: Int = 0
    
    public var isOnScreen: Bool = false
    public var alpha: CGFloat = 1.0
    public var bounds: NSRect = .zero
    public var ownerAppName: String = ""
    public var ownerAppProcessId: Int = 0
    public var memoryUsage: UInt = 0
    
    public var backingStoreType: CGWindowBackingType = .backingStoreNonretained
    public var isBackingStoreOnVideoMemory: Bool = false
    public var sharingType: CGWindowSharingType = .none
    
    public var debugDescription: String {
        return """
            {
                windowId = \(id)
                windowLayer = \(layer)
                windowOrder = \(order)
                windowAlpha = \(alpha)
                windowBounds = \(bounds)
                windowIsOnScreen = \(isOnScreen)
                windowMemoryUsage = \(memoryUsage)
                windowOwnerAppName = \(ownerAppName)
                windowOwnerAppProcessId = \(ownerAppProcessId)
                windowSharingType = \(sharingType)
                windowBackingStoreType = \(backingStoreType)
                windowIsBackingStoreOnVideoMemory = \(isBackingStoreOnVideoMemory)
            }
            """
    }
}

public extension NSWindow {
    
    static func windowInfos(by listOption: CGWindowListOption, relativeToWindow: CGWindowID = kCGNullWindowID, filter: ((WindowInfo) -> Bool)? = nil) -> [WindowInfo] {
        guard let windowInfoDictionaries = CGWindowListCopyWindowInfo(listOption, relativeToWindow) as? [[String: Any]] else {
            return []
        }
        
        var windowInfos = [WindowInfo]()
        for (index, windowInfo) in windowInfoDictionaries.enumerated() {
            var info = WindowInfo()
            
            if let value = windowInfo[kCGWindowSharingState as String] as? UInt32,
               let sharingType = CGWindowSharingType(rawValue: value) {
                info.sharingType = sharingType
            }
            
            if let id = windowInfo[kCGWindowNumber as String] as? Int {
                info.id = id
            }
            
            info.order = index
            
            if let layer = windowInfo[kCGWindowLayer as String] as? Int {
                info.layer = layer
            }
            
            if let alpha = windowInfo[kCGWindowLayer as String] as? Int {
                info.layer = alpha
            }
            
            if let appName = windowInfo[kCGWindowOwnerName as String] as? String {
                info.ownerAppName = appName
            }
            
            if let pid = windowInfo[kCGWindowOwnerPID as String] as? Int {
                info.ownerAppProcessId = pid
            }
            
            if let isOnScreen = windowInfo[kCGWindowIsOnscreen as String] as? Bool {
                info.isOnScreen = isOnScreen
            }
            
            if let boundsInfo = windowInfo[kCGWindowBounds as String] as? [String: Any],
               let bounds = CGRect(dictionaryRepresentation: boundsInfo as CFDictionary) {
                info.bounds = bounds
            }
            
            if let memoryUsed = windowInfo[kCGWindowMemoryUsage as String] as? UInt {
                info.memoryUsage = memoryUsed
            }
            
            if let value = windowInfo[kCGWindowStoreType as String] as? UInt32, let storeType = CGWindowBackingType(rawValue: value) {
                info.backingStoreType = storeType
            }
            
            if let isOnVideoMemory = windowInfo[kCGWindowBackingLocationVideoMemory as String] as? Bool {
                info.isBackingStoreOnVideoMemory = isOnVideoMemory
            }
            
            if let aFilter = filter {
                if aFilter(info) {
                    windowInfos.append(info)
                }
            } else {
                windowInfos.append(info)
            }
        }
    
        return windowInfos
    }
    
}

#endif
