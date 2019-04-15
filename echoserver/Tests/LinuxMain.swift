import XCTest

import Server

var tests = [XCTestCaseEntry]()
tests += ServerTests.allTests()
XCTMain(tests)