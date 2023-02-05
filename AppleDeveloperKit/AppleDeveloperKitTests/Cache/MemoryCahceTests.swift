//
//  MemoryCahceTests.swift
//  AppleDeveloperKitTests
//
//  Created by Evan Xie on 2023/2/5.
//

import XCTest
import AppleDeveloperKit

final class MemoryCahceTests: XCTestCase {

    let itemSize: UInt = 1000 * 1000 // 1MB
    
    private func makeTestData(_ numberOfBytes: UInt) -> Data {
        return Data(repeating: 0, count: Int(numberOfBytes))
    }
    
    func testCacheCount() throws {
        let cache = MemoryCache<String, Data>(costLimit: itemSize * 10, countLimit: 10)
        for index in 1...5 {
            cache.cacheItem(makeTestData(itemSize), forKey: "\(index)", cost: itemSize)
        }
        cache.removeItem(forKey: "2")
        cache.removeItem(forKey: "3")
        XCTAssertEqual(cache.totalCount, 3)
        XCTAssertEqual(cache.totalCost, 3 * itemSize)
    }
    
    func testCacheCostLimit() throws {
        let cache = MemoryCache<String, Data>(costLimit: itemSize * 10, countLimit: 10)
        for index in 1...10 {
            cache.cacheItem(makeTestData(itemSize), forKey: "\(index)", cost: itemSize)
        }
        XCTAssertEqual(cache.totalCost, 10 * itemSize)
    }
    
    func testCacheCountLimit() throws {
        let cache = MemoryCache<String, Data>(costLimit: 0, countLimit: 3)
        for index in 1...5 {
            cache.cacheItem(makeTestData(itemSize), forKey: "\(index)", cost: itemSize)
        }
        XCTAssertEqual(cache.totalCount, cache.countLimit)
    }
    
    func testCacheRemove() throws {
        let cache = MemoryCache<String, Data>()
        for index in 1...20 {
            cache.cacheItem(makeTestData(itemSize), forKey: "\(index)", cost: itemSize)
        }
        cache.removeAll()
        XCTAssertEqual(cache.totalCount, 0)
        XCTAssertEqual(cache.totalCost, 0)
    }
    
    func testThreadSafePeformance() throws {
        let cache = MemoryCache<String, Data>()
        cache.isThreadSafe = true
        
        let queue = DispatchQueue(label: "TestQueue.MemeoryCache", attributes: .concurrent)
        let group = DispatchGroup()
        let count = 1000
        
        for index in 1...count {
            queue.async(group: group, execute: {
                cache.cacheItem(self.makeTestData(self.itemSize), forKey: "\(index)", cost: self.itemSize)
            })
        }
        
        group.wait()
        XCTAssertEqual(cache.totalCost, UInt(count) * itemSize)
        XCTAssertEqual(cache.totalCount, UInt(count))
    }

}
