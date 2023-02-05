//
//  VersionTests.swift
//  AppleDeveloperKitTests
//
//  Created by Evan Xie on 2023/2/5.
//

import XCTest
import AppleDeveloperKit

final class VersionTests: XCTestCase {

    func testVersionCompare() {
        var version1 = Version("1.2.3")
        var version2 = Version("1.2")
        XCTAssertTrue(version1 > version2)
        XCTAssertEqual(version1.major, 1)
        XCTAssertEqual(version1.minor, 2)
        
        version1 = Version("2.0")
        version2 = Version("1.2.5")
        XCTAssertTrue(version1 > version2)
        XCTAssertTrue(version1 >= version2)
        
        version1 = Version("2.0")
        version2 = Version("3.4")
        XCTAssertTrue(version1 < version2)
        XCTAssertTrue(version1 != version2)
        XCTAssertTrue(version1 <= version2)
        
        version1 = Version("2.0")
        version2 = Version("2.0")
        XCTAssertTrue(version1 == version2)
        
        version1 = Version("1.0_Beta")
        XCTAssertEqual(version1.isValid, false)
        XCTAssertEqual(version1.major, 0)
        XCTAssertEqual(version1.minor, 0)
    }

}
