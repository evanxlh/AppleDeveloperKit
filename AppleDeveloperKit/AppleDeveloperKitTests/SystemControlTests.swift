//
//  SystemControlTests.swift
//  AppleDeveloperKitTests
//
//  Created by Evan Xie on 2023/2/12.
//

import XCTest
import AppleDeveloperKit

final class SystemControlTests: XCTestCase {

    func testSysctl() throws {
        let result1: Int32? = SystemControl.fixedWidthIntValue(byName: "hddfadf")
        XCTAssertTrue(result1 == nil)
        
        let result2: UInt64? = SystemControl.fixedWidthIntValue(byName: "jdafdafd")
        XCTAssertTrue(result2 == nil)
        
        let result3 = SystemControl.stringValue(byName: "aadkdjfdfa")
        XCTAssertTrue(result3 == nil)
        
        let isTranslated = SystemControl.isProcessRunningNatively()
        XCTAssertTrue(isTranslated)
        
        let machine = SystemControl.machine()
        XCTAssertFalse(machine.isEmpty)
        print("\(SystemControl.Name.Hardware.machine.rawValue):  \(machine)")
        
        let model = SystemControl.model()
        XCTAssertFalse(model.isEmpty)
        print("\(SystemControl.Name.Hardware.model.rawValue):  \(model)")
        
        let numberOfCpus = SystemControl.numberOfCPUs()
        XCTAssertTrue(numberOfCpus > 0)
        print("\(SystemControl.Name.Hardware.cpuCores.rawValue):  \(numberOfCpus)")
        
        
        let memorySize = SystemControl.memorySize()
        XCTAssertTrue(memorySize > 0)
        print("\(SystemControl.Name.Hardware.memorySize.rawValue):  \(memorySize)")
    }

}
