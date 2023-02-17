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
        XCTAssertTrue(timer.state == .idle)
        
        timer.schedule(withInterval: 0.001, repeatMode: .always, fireClosure: { _, _ in

        })
        XCTAssertTrue(timer.state == .running)
        
        timer.pause()
        XCTAssertTrue(timer.state == .paused)

        timer.cancel()
        XCTAssertTrue(timer.state == .idle)

        timer.timer?.start()

        timer.resume()
        XCTAssertTrue(timer.state == .idle)
        
        timer.pause()
        XCTAssertTrue(timer.state == .idle)

        timer.cancel()
        XCTAssertTrue(timer.state == .idle)
    }
    
    func testPause() throws {
        let expectation = XCTestExpectation(description: "")
        let timer = DispatchTimer()
        
        let startTimestamp = CFAbsoluteTimeGetCurrent()
        var endTimestamp = startTimestamp

        timer.cancelledCallback = {
            expectation.fulfill()
        }
        
        timer.schedule(withInterval: 0.001, repeatMode: .count(1000), fireClosure: { timer ,info in
            if info.firedTimes == 3 {
                endTimestamp = CFAbsoluteTimeGetCurrent()
            }
            
            if info.firedTimes > 1000 {
                XCTAssertTrue(false, "Fired times exceeds 1000")
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            timer.pause()
            XCTAssertTrue(timer.state == .paused)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
            timer.resume()
            XCTAssertTrue(timer.state == .running)
        }
        
        wait(for: [expectation], timeout: 1.8)
        XCTAssertTrue(endTimestamp - startTimestamp >= 0.003)
        XCTAssertTrue(endTimestamp - startTimestamp <= 0.004)
        XCTAssertTrue(timer.state == .idle)
    }
    
    func testInvalidate() throws {
        let timer = DispatchTimer()
        timer.schedule(withInterval: 0.001, repeatMode: .count(5), fireClosure: { _ , _ in
        })
        
        timer.cancel()
        XCTAssertTrue(timer.state == .idle)
        
        let expectation = XCTestExpectation(description: "")
        
        timer.schedule(withInterval: 0.001, repeatMode: .count(5)) { _, info in
            if info.firedTimes == 5 {
                expectation.fulfill()
            }
        }
        XCTAssertTrue(timer.state == .running)
        
        wait(for: [expectation], timeout: 0.01)
        XCTAssertTrue(timer.state == .idle)
    }

}
