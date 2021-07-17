import XCTest
@testable import Swafka

final class SwafkaTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Swafka().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
