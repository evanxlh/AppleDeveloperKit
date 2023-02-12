//
//  ValidatorTests.swift
//  AppleDeveloperKitTests
//
//  Created by Evan Xie on 2023/2/13.
//

import XCTest
import AppleDeveloperKit

final class ValidatorTests: XCTestCase {
    private var passwordValidator: Validator<String>!

    override func setUpWithError() throws {
        passwordValidator = Validator<String> { string in
            try validate(
                string.count >= 7,
                errorMessage: "Password must contain min 7 characters"
            )

            try validate(
                string.lowercased() != string,
                errorMessage: "Password must contain an uppercased character"
            )

            try validate(
                string.uppercased() != string,
                errorMessage: "Password must contain a lowercased character"
            )
        }
    }

    func testValidationSuccess() {
        let password = "Hello1234"
        do {
            try validate(password, using: passwordValidator)
        } catch {
            XCTAssert(false, "Validation error")
        }
    }

    func testValidationFailure() {
        let password = "abc32"
        do {
            try validate(password, using: passwordValidator)
            XCTAssert(false, "Validation error")
        } catch {
            XCTAssertFalse(false)
        }
    }

}
