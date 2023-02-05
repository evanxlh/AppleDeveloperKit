//
//  ArrayMoveTests.swift
//  AppleDeveloperKitTests
//
//  Created by Evan Xie on 2023/2/5.
//

import XCTest
import AppleDeveloperKit

final class ArrayMoveTests: XCTestCase {

    func testMoveByIndexSet_Multiple() throws {
        var indexSet = IndexSet(arrayLiteral: 0, 1)
        var numbers = [1, 2, 3, 4, 5]
        numbers.moveAtIndexSet(indexSet, toIndex: 5)
        XCTAssertEqual(numbers, [3, 4, 5, 1, 2])
        
        numbers = [1, 2, 3, 4, 5]
        indexSet = IndexSet(arrayLiteral: 2, 4)
        numbers.moveAtIndexSet(indexSet, toIndex: 1)
        XCTAssertEqual(numbers, [1, 3, 5, 2, 4])
    }
    
    func testMoveByIndexSet_Single() throws {
        var indexSet = IndexSet(arrayLiteral: 0)
        var numbers = [1, 2, 3, 4, 5]
        numbers.moveAtIndexSet(indexSet, toIndex: 2)
        XCTAssertEqual(numbers, [2, 1, 3, 4, 5])
        
        indexSet = IndexSet(arrayLiteral: 1)
        numbers = [1, 2, 3, 4, 5]
        numbers.moveAtIndexSet(indexSet, toIndex: 5)
        XCTAssertEqual(numbers, [1, 3, 4, 5, 2])
        
        indexSet = IndexSet(arrayLiteral: 4)
        numbers = [1, 2, 3, 4, 5]
        numbers.moveAtIndexSet(indexSet, toIndex: 0)
        XCTAssertEqual(numbers, [5, 1, 2, 3, 4])
    }
    
    func testRemovingByIndexSet() throws {
        var numbers = [1, 2, 3, 4, 5]
        let indexSet = IndexSet(arrayLiteral: 3, 1, 4)
        numbers.removeAtIndexSet(indexSet)
        XCTAssertEqual(numbers, [1, 3])
    }
}
