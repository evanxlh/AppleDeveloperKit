//
//  FileCacheManager.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/6.
//

import Foundation

/// `FileCacheManager` helps your to manager app file caches.
public final class FileCacheManager {
    
    private var cacheDirectories: [URL]
    
    public init(cacheDirectories: [URL]) {
        self.cacheDirectories = cacheDirectories
    }
    
    /// Add a cache directory to let `FileCacheManager` manage.
    public func addCacheDirectory(_ directoryURL: URL) {
        if !cacheDirectories.contains(directoryURL) {
            cacheDirectories.append(directoryURL)
        }
    }
    
    /// Calucate total size in bytes of managed caches.
    /// All the files and directories under the cache directories are both taken into account.
    ///
    /// - Note: This can be time-consuming, you can use second thread to run this task.
    public func calculateTotalCahceSize() -> UInt64 {
        var cacheSize: UInt64 = 0
        cacheDirectories.forEach({
            cacheSize += FileManager.calculateFileSize(at: $0)
        })
        return cacheSize
    }
    
    /// Clear all cache files which `FileCacheManager` manages on the current thread.
    ///
    /// - Note: This can be time-consuming, you can use second thread to run this task.
    public func clearAll(_ includingCacheDirectoriesSelves: Bool = false) {
        if includingCacheDirectoriesSelves {
            cacheDirectories.forEach {
                try? FileManager.default.removeItem(at: $0)
            }
            return
        }
        cacheDirectories.forEach({
            FileManager.removeDirectoryContent($0)
        })
    }

}
