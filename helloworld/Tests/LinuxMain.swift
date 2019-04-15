import XCTest

import helloworldTests

var tests = [XCTestCaseEntry]()
tests += helloworldTests.allTests()
XCTMain(tests)
