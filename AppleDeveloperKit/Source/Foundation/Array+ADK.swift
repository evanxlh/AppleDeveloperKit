//
//  Array+ADK.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/5.
//

import Foundation

public extension Array {
    
    /// Move a group of items to destination index(`toIndex`).
    mutating func moveAtIndexSet(_ indexSet: IndexSet, toIndex: Int) {
        if indexSet.count == 0 { return }
        
        let indexes = indexSet.sorted(by: { $0 < $1 })
        
        // Store the elements will be moved to an extra array
        var willMoved = [Element]()
        indexes.forEach {
            willMoved.append(self[$0])
        }
        
        // Remove the elements that will be moved from source array.
        // Remove greater index firstly, to avoid out of bounds
        var actualToIndex = toIndex
        for index in (0...indexes.count - 1).reversed() {
            if indexes[index] < toIndex {
                actualToIndex -= 1
            }
            remove(at: indexes[index])
        }
        
        if actualToIndex >= count {
            append(contentsOf: willMoved)
        } else {
            for index in (0...willMoved.count - 1).reversed() {
                insert(willMoved[index], at: actualToIndex)
            }
        }
    }
    
    mutating func removeAtIndexSet(_ indexSet: IndexSet) {
        // Remove greater index firstly, to avoid out of bounds
        let indexes = indexSet.sorted(by: { $0 > $1 })
        for index in 0...indexes.count - 1 {
            remove(at: indexes[index])
        }
    }
    
}
