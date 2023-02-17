//
//  MemoryMonitorTest.swift
//  AppleDeveloperKitTests
//
//  Created by Evan Xie on 2023/2/17.
//

import XCTest
import AppleDeveloperKit

class AnyMemoryObserver: MemoryWarningObserver {
    let name: String
    init(name: String) {
        self.name = name
    }

    func didReceiveMemoryWarningEvent() {
        print("\(name) receive memory warning")
    }
}

final class MemoryMonitorTest: XCTestCase {

    func testWarningObserver() {
        let observer1: AnyMemoryObserver = AnyMemoryObserver(name: "AnyMemoryObserver 1")
        let observer2: AnyMemoryObserver = AnyMemoryObserver(name: "AnyMemoryObserver 2")
        var observer3: AnyMemoryObserver? = AnyMemoryObserver(name: "AnyMemoryObserver 3")
        MemoryMonitor.shared.addWarningObserver(observer1)
        MemoryMonitor.shared.addWarningObserver(observer2)
        MemoryMonitor.shared.addWarningObserver(observer3!)
        MemoryMonitor.shared.start()

        observer3 = nil
        XCTAssertTrue(MemoryMonitor.shared.observers.count == 2)
    }

    func testMemoryState() {
        if let state = Memory.state() {
            print(state)
        }
    }

}
