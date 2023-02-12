//
//  WeakObjectsTests.swift
//  AppleDeveloperKitTests
//
//  Created by Evan Xie on 2023/2/12.
//

import XCTest
import AppleDeveloperKit


class Person {
    var name: String = "No name"
    var age: Int = 0
}

final class WeakObjectsTests: XCTestCase {

    func testWeakObjects() throws {
        let weakObjects = WeakObjects<Person>()
        let person1 = Person()
        let person2 = Person()
        let person3 = Person()
        var person4: Person? = Person()

        weakObjects.addObject(person1)
        weakObjects.addObject(person2)
        weakObjects.addObject(person3)
        weakObjects.removeObject(person2)
        XCTAssertTrue(weakObjects.count == 2)
        weakObjects.addObject(person4!)

        person4 = nil

        let expect = expectation(description: "")
        DispatchQueue.main.async {
            XCTAssertTrue(weakObjects.count == 2)
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

}
