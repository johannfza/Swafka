import XCTest

import SwafkaTests

var tests = [XCTestCaseEntry]()
tests += SwafkaTests.allTests()
XCTMain(tests)
