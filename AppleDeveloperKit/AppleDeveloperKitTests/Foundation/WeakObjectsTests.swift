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

        weakObjects.append(person1)
        weakObjects.append(person2)
        weakObjects.append(person3)
        weakObjects.remove(person2)
        XCTAssertTrue(weakObjects.count == 2)
        weakObjects.append(person4!)

        person4 = nil

        let expect = expectation(description: "")
        DispatchQueue.global().async {
            XCTAssertTrue(weakObjects.count == 2)
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

    func testAnyWeakObjects() throws {
        let weakObjects = AnyWeakObjects()
        let person1 = Person()
        let person2 = Person()
        var person3: Person? = Person()
        var person4: Person? = Person()

        weakObjects.append(person1)
        weakObjects.append(person2)
        weakObjects.append(person3!)
        weakObjects.remove(person2)
        XCTAssertTrue(weakObjects.count == 2)
        weakObjects.append(person4!)

        person3 = nil
        person4 = nil

        let expect = expectation(description: "")
        DispatchQueue.global().async {
            XCTAssertTrue(weakObjects.count == 1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

}
