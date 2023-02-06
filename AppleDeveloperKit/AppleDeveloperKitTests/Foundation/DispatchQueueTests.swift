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
            XCTAssertTrue(self.queue1.adk.isCurrent)
            XCTAssertFalse(self.queue2.adk.isCurrent)
            XCTAssertFalse(self.queue1.adk.isMain)
        }
        
        queue2.async {
            XCTAssertTrue(self.queue2.adk.isCurrent)
            XCTAssertFalse(self.queue1.adk.isCurrent)
            XCTAssertFalse(self.queue2.adk.isMain)
        }
        
        DispatchQueue.main.async {
            XCTAssertFalse(self.queue2.adk.isCurrent)
            XCTAssertFalse(self.queue1.adk.isCurrent)
            XCTAssertTrue(DispatchQueue.main.adk.isMain)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1), execute: {
            flag.fulfill()
        })
        
        waitForExpectations(timeout: 1.3) { error in
            print("testIsCurrentQueue timeout: \(String(describing: error?.localizedDescription))")
        }
    }

}
