import XCTest
@testable import Swafka

final class BrokerTests: XCTestCase {
    
    var sut: Broker<TestTopic>!
        
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = Broker()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test: subscribe()
    func test_subscribe_whenTopicIsPublished_consumerCompletionCompletesOnMainThread() {
        let expectConsumerCompletionToComplete = XCTestExpectation(description: "Expecting completion to complete")
        var testTopic: TestTopic? = nil
        var isMainThread: Bool? = nil
        sut.subscribe(self) { (topic: TestTopic) in
            testTopic = topic
            isMainThread = Thread.isMainThread
            expectConsumerCompletionToComplete.fulfill()
        }
        sut.publish(topic: TestTopic.success)
        wait(for: [expectConsumerCompletionToComplete], timeout: 1)
        XCTAssertTrue(isMainThread!)
        XCTAssertEqual(testTopic!, TestTopic.success)
    }
    
    func test_subscribe_whenTopicIsPublished_consumerCompletionCompletesOnBackgroundQueue() {
        let expectConsumerCompletionToComplete = XCTestExpectation(description: "Expecting completion to complete")
        var testTopic: TestTopic? = nil
        var isBackgroundThread: Bool? = nil
        let queue = DispatchQueue(label: "background_queue_test", qos: .background)
        sut.subscribe(self, thread: .background(queue: queue)) { (topic: TestTopic) in
            testTopic = topic
            isBackgroundThread = Thread.current.qualityOfService.rawValue == 9
            expectConsumerCompletionToComplete.fulfill()
        }
        sut.publish(topic: TestTopic.success)
        wait(for: [expectConsumerCompletionToComplete], timeout: 1)
        XCTAssertTrue(isBackgroundThread!)
        XCTAssertEqual(testTopic!, TestTopic.success)
    }
    
    func test_subscribe_whenConsumerSibscribesAndTopicHasLog_consumerCompletionIsCompletedWithLog() {
        let expectConsumerCompletionToComplete = XCTestExpectation(description: "Expecting completion to complete")
        sut.publish(topic: TestTopic.success)
        XCTAssertNotNil(sut.getLastLog() as TestTopic?, "Precondition: Log should contain one entry")
        var testTopic: TestTopic? = nil
        sut.subscribe(self) { (topic: TestTopic) in
            testTopic = topic
            expectConsumerCompletionToComplete.fulfill()
        }
        wait(for: [expectConsumerCompletionToComplete], timeout: 1)
        XCTAssertEqual(testTopic!, TestTopic.success)
    }
    
    func test_subscribe_whenConsumerSubscribesWithgetInitialStateFalseAndIfLogHasEntry_consumerCompletionDoesNotComplete() {
        sut.publish(topic: TestTopic.success)
        XCTAssertNotNil(sut.getLastLog() as TestTopic?, "Precondition: Log should contain one entry")
        var testTopic: TestTopic? = nil
        sut.subscribe(self, getInitialState: false) { (topic: TestTopic) in
            testTopic = topic
        }
        let timeBuffer = XCTestExpectation(description: "Time buffer to make sure not more are updates are made")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            timeBuffer.fulfill()
        }
        wait(for: [timeBuffer], timeout: 1)
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
        sut.unsubscribe(self)
        sut.publish(topic: TestTopic.failure)
        let timeBuffer = XCTestExpectation(description: "Time buffer to make sure not more are updates are made")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            timeBuffer.fulfill()
        }
        XCTAssertEqual(testTopic!, TestTopic.success)
    }
    
    // MARK: - Test: publish()
    func test_publish_whenBrokerPublishesTopic_consumerCompletionCompletes() {
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
    
    func test_publish_whenBrokerPublishesTopic_topisIsAppenedToLog() {
        XCTAssertNil(sut.getLastLog() as TestTopic?, "Precondition: Log should contain no entry")
        sut.publish(topic: TestTopic.success)
        XCTAssertNotNil(sut.getLastLog() as TestTopic?)
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
        let testTopic: TestTopic? = sut.getLastLog()
        XCTAssertNil(testTopic)
    }
    
    func test_getLastLog_whenLogHasLastValue_returnsLastValue() {
        sut.publish(topic: TestTopic.success)
        let testTopic: TestTopic? = sut.getLastLog()
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
    
    func test_subscribeOnActive_whenFirstConsumerSubscribesToTopic_onActiveConsumerCompletionCompletesOnBackgroundQueue() {
        let expectation = self.expectation(description: "Expecting completion to complete")
        var testTopic: Any? = nil
        var isBackgroundThread: Bool? = nil
        let queue = DispatchQueue(label: "background_queue", qos: .background)
        sut.subscribeOnActive(self, thread: .background(queue: queue)) { (topicType: TestTopic.Type) in
            testTopic = topicType
            isBackgroundThread = Thread.current.qualityOfService.rawValue == 9
            expectation.fulfill()
        }
        sut.subscribe(self) { (topic: TestTopic) in }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(isBackgroundThread!)
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
        var isMainThread: Bool? = nil
        sut.subscribeOnInactive(self) { (topicType: TestTopic.Type) in
            testTopic = topicType
            isMainThread = Thread.isMainThread
            expectOnInactiveConsumerCompletionToComplete.fulfill()
        }
        sut.subscribe(self) { (topic: TestTopic) in
            XCTAssertEqual(topic, TestTopic.success, "Precondition: Broker should have consumer")
            expectConsumerCompletionToComplete.fulfill()
        }
        sut.publish(topic: TestTopic.success)
        sut.unsubscribe(self)
        wait(for: [expectConsumerCompletionToComplete, expectOnInactiveConsumerCompletionToComplete], timeout: 1)
        XCTAssertTrue(isMainThread!)
        XCTAssertTrue(testTopic is TestTopic.Type)
    }
    
    func test_subscribeOnInactive_whenTheOnlyConsumerUsubscribes_onInactiveConsumerCompletionCompletesOnBackgroundThread() {
        let expectConsumerCompletionToComplete = XCTestExpectation(description: "Expecting completion to complete")
        let expectOnInactiveConsumerCompletionToComplete = XCTestExpectation(description: "Expecting completion to complete")
        let queue = DispatchQueue(label: "background_queue_test", qos: .background)
        var testTopic: Any? = nil
        var isBackgroundThread: Bool? = nil
        sut.subscribeOnInactive(self, thread: .background(queue: queue)) { (topicType: TestTopic.Type) in
            testTopic = topicType
            isBackgroundThread = Thread.current.qualityOfService.rawValue == 9
            expectOnInactiveConsumerCompletionToComplete.fulfill()
        }
        sut.subscribe(self) { (topic: TestTopic) in
            XCTAssertEqual(topic, TestTopic.success, "Precondition: Broker should have consumer")
            expectConsumerCompletionToComplete.fulfill()
        }
        sut.publish(topic: TestTopic.success)
        sut.unsubscribe(self)
        wait(for: [expectConsumerCompletionToComplete, expectOnInactiveConsumerCompletionToComplete], timeout: 1)
        XCTAssertTrue(isBackgroundThread!)
        XCTAssertTrue(testTopic is TestTopic.Type)
    }
}
