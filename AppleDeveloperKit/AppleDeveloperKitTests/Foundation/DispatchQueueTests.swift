//
//  DispatchQueueTests.swift
//  AppleDeveloperKitTests
//
//  Created by Evan Xie on 2023/2/5.
//

import XCTest
import AppleDeveloperKit

final class DispatchQueueTests: XCTestCase {
    let queue1 = DispatchQueue(label: "SerialQueue1")
    let queue2 = DispatchQueue(label: "SerialQueue2")

    func testIsCurrentQueue() throws {
        
        let flag = self.expectation(description: "wait")
        
        queue1.async {
            XCTAssertTrue(DispatchQueue.isCurrent(self.queue1))
            XCTAssertFalse(DispatchQueue.isCurrent(self.queue2))
            XCTAssertFalse(DispatchQueue.isMain)
        }
        
        queue2.async {
            XCTAssertTrue(DispatchQueue.isCurrent(self.queue2))
            XCTAssertFalse(DispatchQueue.isCurrent(self.queue1))
            XCTAssertFalse(DispatchQueue.isMain)
        }
        
        DispatchQueue.main.async {
            XCTAssertFalse(DispatchQueue.isCurrent(self.queue2))
            XCTAssertFalse(DispatchQueue.isCurrent(self.queue1))
            XCTAssertTrue(DispatchQueue.isMain)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1), execute: {
            flag.fulfill()
        })
        
        waitForExpectations(timeout: 1.3) { error in
            print("testIsCurrentQueue timeout: \(String(describing: error?.localizedDescription))")
        }
    }

}
