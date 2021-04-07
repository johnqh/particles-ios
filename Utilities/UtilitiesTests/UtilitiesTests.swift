//
//  UtilitiesTests.swift
//  UtilitiesTests
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import XCTest
@testable import Utilities

class UtilitiesTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStrings() {
        let string = "this/is/a/test.json"
        XCTAssert(string.lastPathComponent == "test.json", "lastPathComponent error")
        XCTAssert(string.pathExtension == "json", "pathExtension error")
        XCTAssert(string.stringByDeletingLastPathComponent == "this/is/a", "stringByDeletingLastPathComponent error")
        XCTAssert(string.stringByDeletingPathExtension == "this/is/a/test", "stringByDeletingPathExtension error")
        XCTAssert(string.pathComponents == ["this", "is", "a", "test.json"], "pathComponents error")
        XCTAssert(string.stringByAppendingPathComponent(path: "another") == "this/is/a/test.json/another", "stringByAppendingPathComponent error")
        XCTAssert(string.stringByAppendingPathExtension(ext: "pdf") == "this/is/a/test.json.pdf", "stringByAppendingPathExtension error")
        
        XCTAssert(string.begins(with: "this"), "begins error")
        XCTAssert(!string.begins(with: "thisx"), "begins error")
        
        XCTAssert(string.ends(with: "test.json"), "ends error")
        XCTAssert(!string.ends(with: "test_json"), "ends error")
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
