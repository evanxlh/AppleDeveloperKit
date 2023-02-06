//
//  FileManager+ADK.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/6.
//

import Foundation

//MARK: - Common Directory URLs

public extension FileManager {
    
    static var homeDirectoryURL: URL {
        return URL(fileURLWithPath: NSHomeDirectory())
    }
    
    static var documentsDirectoryURL: URL {
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    }
    
    static var applicationSupportDirectoryURL: URL {
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0])
    }
    
    static var cachesDirectoryURL: URL {
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0])
    }
    
    static var libraryDirectoryURL: URL {
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])
    }
    
    static var tempDirectoryURL: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
    }
    
}

public extension FileManager {
    
    static func removeDirectoryContent(_ directoryURL: URL) {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])
            urls.forEach {
                do {
                    try FileManager.default.removeItem(at: $0)
                } catch {
                    print("Remove directory content error: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Get directory content error: \(error.localizedDescription)")
        }
    }
}

// MARK: - File Size & Disk Free Space

public extension FileManager {
    
    /// Calculate the disk space occupied of given file/folder.
    static func calculateFileSize(at fileURL: URL) -> UInt64 {
        let fm = FileManager.default
        let realURL = fileURL.resolvingSymlinksInPath()
        guard let attrs = try? fm.attributesOfItem(atPath: realURL.path),
              let fileType = attrs[FileAttributeKey.type] as? FileAttributeType
        else {
            return 0
        }
        
        if fileType != .typeDirectory {
            return (attrs[FileAttributeKey.size] as? UInt64) ?? 0
        }
        
        guard let enumerator = fm.enumerator(at: realURL, includingPropertiesForKeys: nil) else {
            return 0
        }
        
        var totalSize: UInt64 = 0
        while let url = enumerator.nextObject() as? URL {
            let realURUL = url.resolvingSymlinksInPath()
            guard let attrs = try? FileManager.default.attributesOfItem(atPath: realURUL.path) else { continue }
            guard let fileType = attrs[FileAttributeKey.type] as? FileAttributeType else { continue }
            guard fileType == .typeRegular else { continue }
            guard let fileSize = attrs[FileAttributeKey.size] as? UInt64 else { continue }
            totalSize += fileSize
        }
        return totalSize
    }
    
    /// Get the local disk free space and total space in bytes.
    static func getDiskSpaceUsage() -> DiskSpaceUsage {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) else {
            return DiskSpaceUsage(freeSpace: 0, totalSpace: 0)
        }
        let totalSapce = attrs[FileAttributeKey.systemSize] as? UInt64 ?? 0
        let freeSpace = attrs[FileAttributeKey.systemFreeSize] as? UInt64 ?? 0
        return DiskSpaceUsage(freeSpace: freeSpace, totalSpace: totalSapce)
    }
    
    struct DiskSpaceUsage: CustomDebugStringConvertible {
        public var freeSpace: UInt64
        public var totalSpace: UInt64
        
        public var debugDescription: String {
            var desc = "Disk Space: [\n"
            desc.append("\tFree: \(ByteCountFormatter.string(fromByteCount: Int64(freeSpace), countStyle: .file)),\n")
            desc.append("\tTotal: \(ByteCountFormatter.string(fromByteCount: Int64(totalSpace), countStyle: .memory))\n]")
            return desc
        }
    }
}
