//
//  DispatchTimerTests.swift
//  AppleDeveloperKitTests
//
//  Created by Evan Xie on 2023/2/5.
//

import XCTest
import AppleDeveloperKit

final class DispatchTimerTests: XCTestCase {

    func testStates() throws {
        let timer = DispatchTimer()
        XCTAssertTrue(timer.currentState == .idle)
        
        timer.schedule(withInterval: 1.0, repeatMode: .count(3), fireClosure: { _, _ in
            
        })
        XCTAssertTrue(timer.currentState == .running)
        
        timer.pause()
        XCTAssertTrue(timer.currentState == .paused)
        
        timer.resume()
        XCTAssertTrue(timer.currentState == .running)
        
        timer.invalidate()
        XCTAssertTrue(timer.currentState == .idle)
    }
    
    func testPause() throws {
        let expectation = XCTestExpectation(description: "")
        let timer = DispatchTimer()
        
        let startTimestamp = CFAbsoluteTimeGetCurrent()
        var endTimestamp = startTimestamp
        
        timer.schedule(withInterval: 1.0, repeatMode: .count(3), fireClosure: { timer ,info in
            
            if info.firedTimes == 3 {
                endTimestamp = CFAbsoluteTimeGetCurrent()
                print("ℹ️ DispathTimer ending timestamp: \(endTimestamp - startTimestamp)")
                expectation.fulfill()
            }
            
            if info.firedTimes > 3 {
                XCTAssertTrue(false, "Fired times exceeds 2")
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            timer.pause()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2500)) {
            timer.resume()
        }
        
        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(endTimestamp - startTimestamp > 3)
        XCTAssertTrue(timer.currentState == .idle)
    }
    
    func testInvalidate() throws {
        let timer = DispatchTimer()
        timer.schedule(withInterval: 0.1, repeatMode: .count(5), fireClosure: { _ , _ in
        })
        
        timer.invalidate()
        XCTAssertTrue(timer.currentState == .idle)
        
        let expectation = XCTestExpectation(description: "")
        
        timer.schedule(withInterval: 0.1, repeatMode: .count(5)) { _, info in
            if info.firedTimes == 5 {
                expectation.fulfill()
            }
        }
        XCTAssertTrue(timer.currentState == .running)
        
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(timer.currentState == .idle)
    }

}
