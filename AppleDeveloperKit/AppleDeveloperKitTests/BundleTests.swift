//
//  BundleTests.swift
//  AppleDeveloperKitTests
//
//  Created by Evan Xie on 2023/2/5.
//

import XCTest
import AppleDeveloperKit

final class BundleTests: XCTestCase {

    func testBundle() throws {
        let bundleIdentifier = "me.evanxlh.AppleDeveloperKit"
        guard let bundle = Bundle(identifier: bundleIdentifier) else {
            print("🔴 bundle(\(bundleIdentifier) not exists")
            return
        }
        
        let libraryBundle = AppleBundle(bundle)
        XCTAssertEqual(libraryBundle.bundleID, bundleIdentifier)
        XCTAssertEqual(libraryBundle.name, "AppleDeveloperKit")
        XCTAssertEqual(libraryBundle.displayName, "AppleDeveloperKit")
        XCTAssertEqual(libraryBundle.executableName, "AppleDeveloperKit")
        XCTAssertEqual(libraryBundle.shortVersion, "1.0")
        XCTAssertEqual(libraryBundle.buildNumber, "1")
        XCTAssertEqual(libraryBundle.fullVersion, "1.0(1)")
    }

}
