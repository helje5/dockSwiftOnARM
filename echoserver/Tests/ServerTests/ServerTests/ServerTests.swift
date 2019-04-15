import XCTest
@testable import Server
import SmokeOperations
import NIOHTTP1
import SmokeHTTP1

final class ServerTests: XCTestCase {
    func testEcho() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }

    static var allTests = [
        ("testExample", testEcho),
    ]
}
