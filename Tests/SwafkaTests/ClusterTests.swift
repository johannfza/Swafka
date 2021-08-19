import XCTest
@testable import Swafka

final class ClusterTests: XCTestCase {
    
    var sut: Cluster!
        
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut =  Cluster()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test: subscribe()
    func test_subscribe_whenTopicIsPublished_consumerCompletionCompletes() {
        let expectConsumerCompletionToComplete = XCTestExpectation(description: "Expecting completion to complete")
        var testTopic: TestTopic? = nil
        sut.subscribe(self) { (topic: TestTopic) in
            testTopic = topic
            expectConsumerCompletionToComplete.fulfill()
        }
        sut.publish(topic: TestTopic.success)
        wait(for: [expectConsumerCompletionToComplete], timeout: 1)
        XCTAssertEqual(testTopic!, TestTopic.success)
    }
    
    func test_subscribe_whenConsumerSibscribesAndTopicHasLog_consumerCompletionIsCompletedWithLog() {
        let expectation = self.expectation(description: "Expecting completion to complete")
        sut.publish(topic: TestTopic.success)
        var testTopic: TestTopic? = nil
        sut.subscribe(self) { (topic: TestTopic) in
            testTopic = topic
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(testTopic!, TestTopic.success)
    }

    func test_subscribe_whenConsumerSubscribesWithgetInitialStateFalseAndIfLogHasEntry_consumerCompletionDoesNotComplete() {
        sut.publish(topic: TestTopic.success)
        var testTopic: TestTopic? = nil
        sut.subscribe(self, getInitialState: false) { (topic: TestTopic) in
            testTopic = topic
        }
        XCTAssertNil(testTopic)
    }

    // MARK: - Test: unsubscribe()
    func test_unsubscribe_whenConsumerUnsubscribesAndTopicIsPublished_consumerCompletionDoesNotComplete() {
        let expectConsumerCompletionToComplete = XCTestExpectation(description: "Expecting completion to complete")
        var testTopic: TestTopic? = nil
        sut.subscribe(self) { (topic: TestTopic) in
            testTopic = topic
            expectConsumerCompletionToComplete.fulfill()
        }
        sut.publish(topic: TestTopic.success)
        wait(for: [expectConsumerCompletionToComplete], timeout: 1)
        XCTAssertEqual(testTopic!, TestTopic.success, "Precondition: Consumer should be successfully subscribed")
        sut.unsubscribe(self, from: TestTopic.self)
        sut.publish(topic: TestTopic.failure)
        let timeBuffer = XCTestExpectation(description: "Time buffer to make sure not more are updates are made")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            timeBuffer.fulfill()
        }
        wait(for: [timeBuffer], timeout: 2)
        XCTAssertEqual(testTopic!, TestTopic.success)
    }

    // MARK: - Test: publish()
    func test_publish_whenBrokerPublishesTopic_topicIsAppenedToLog() {
        XCTAssertNil(sut.getLastLog(of: TestTopic.self), "Precondition: Log should contain no entry")
        sut.publish(topic: TestTopic.success)
        XCTAssertNotNil(sut.getLastLog(of: TestTopic.self))
    }

    func test_publish_whenBrokerPublishesTopic_consumerRecievesTopic() {
        let expectConsumerCompletionToComplete = XCTestExpectation(description: "Expecting completion to complete")
        var testTopic: TestTopic? = nil
        sut.subscribe(self) { (topic: TestTopic) in
            testTopic = topic
            expectConsumerCompletionToComplete.fulfill()
        }
        sut.publish(topic: TestTopic.success)
        wait(for: [expectConsumerCompletionToComplete], timeout: 1)
        XCTAssertEqual(testTopic!, TestTopic.success)
    }

    // MARK: - Test: getLastLog()
    func test_getLastLog_whenLogIsEmpty_returnsNil() {
        let testTopic: TestTopic? = sut.getLastLog(of: TestTopic.self)
        XCTAssertNil(testTopic)
    }

    func test_getLastLog_whenLogHasLastValue_returnsLastValue() {
        sut.publish(topic: TestTopic.success)
        let testTopic: TestTopic? = sut.getLastLog(of: TestTopic.self)
        XCTAssertEqual(testTopic!, TestTopic.success)
    }

    // MARK: - Test: subscribeOnActive()
    func test_subscribeOnActive_whenFirstConsumerSubscribesToTopic_onActiveConsumerCompletionCompletes() {
        let expectation = self.expectation(description: "Expecting completion to complete")
        var testTopic: Any? = nil
        sut.subscribeOnActive(self) { (topicType: TestTopic.Type) in
            testTopic = topicType
            expectation.fulfill()
        }
        sut.subscribe(self) { (topic: TestTopic) in }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(testTopic is TestTopic.Type)
    }

    func test_subscribeOnActive_whenNotFirstConsumerSubscribes_onActiveConsumerCompletionCompletes() {
        let expectFirstCompletionToComplete = XCTestExpectation(description: "Expecting first completion to complete")
        let expectSecondCompletionToComplete = XCTestExpectation(description: "Expecting second completion to complete")
        var count = 0
        var testTopic: Any? = nil
        sut.subscribeOnActive(self) { (topicType: TestTopic.Type) in
            testTopic = topicType
            count += 1
        }
        sut.subscribe(self) { (topic: TestTopic) in
            XCTAssertEqual(topic, TestTopic.success, "Precondition: First consumer should be successfully subscribed")
            expectFirstCompletionToComplete.fulfill()
        }
        sut.subscribe(self) { (topic: TestTopic) in
            XCTAssertEqual(topic, TestTopic.success, "Precondition: Second consumer should be successfully subscribed")
            expectSecondCompletionToComplete.fulfill()
        }
        sut.publish(topic: TestTopic.success)
        wait(for: [expectFirstCompletionToComplete, expectSecondCompletionToComplete], timeout: 1)
        XCTAssertEqual(count, 1)
        XCTAssertTrue(testTopic is TestTopic.Type)
    }

    // MARK: - Test: subscribeOnInactive()
    func test_subscribeOnInactive_whenTheOnlyConsumerUsubscribes_onInactiveConsumerCompletionCompletes() {
        let expectConsumerCompletionToComplete = XCTestExpectation(description: "Expecting completion to complete")
        let expectOnInactiveConsumerCompletionToComplete = XCTestExpectation(description: "Expecting completion to complete")
        var testTopic: Any? = nil
        sut.subscribeOnInactive(self) { (topicType: TestTopic.Type) in
            testTopic = topicType
            expectOnInactiveConsumerCompletionToComplete.fulfill()
        }
        sut.subscribe(self) { (topic: TestTopic) in
            XCTAssertEqual(topic, TestTopic.success, "Precondition: Broker should have consumer")
            expectConsumerCompletionToComplete.fulfill()
        }
        sut.publish(topic: TestTopic.success)
        sut.unsubscribe(self, from: TestTopic.self)
        wait(for: [expectConsumerCompletionToComplete, expectOnInactiveConsumerCompletionToComplete], timeout: 1)
        XCTAssertTrue(testTopic is TestTopic.Type)
    }
    
    func test_clearLog_whenConsumerSubscribeAndHasNoLog_initialStateNoLongerProvided() {
        let expectation = self.expectation(description: "Expecting completion to complete")
        sut.publish(topic: TestTopic.success)
        var testTopic: TestTopic? = nil
        var testTopic2: TestTopic? = nil
        sut.subscribe(self) { (topic: TestTopic) in
            testTopic = topic
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(testTopic!, TestTopic.success)
        sut.clearLog(topic: TestTopic.self)
        let timeBuffer = XCTestExpectation(description: "Time buffer for initializing with initial market status")
        sut.subscribe(self) { (topic: TestTopic) in
            testTopic2 = topic
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            timeBuffer.fulfill()
        }
        wait(for: [timeBuffer], timeout: 2)
        XCTAssertNil(testTopic2)
    }
}
