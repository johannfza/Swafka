import XCTest
@testable import Swafka

public enum TestTopic1: Topicable {
    case failure
    case success
}

public enum TestTopic2: Topicable {
    case failure
    case success
}

public enum TestTopic3: Topicable {
    case failure
    case success
}


final class SwafkaTests: XCTestCase {
    
    var sut: Swafka!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = Swafka()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testSwafkaInitialization() {
        measure {
            _ = Swafka()
        }
    }
    
    func testPubishingSavesTopicState() {
        Swafka.shared.publish(topic: TestTopic1.success)
        let topic = Swafka.shared.getLastLog(of: TestTopic1.self)
        XCTAssertEqual(topic, TestTopic1.success)
    }

    func testPublishingUpdatesTopicState() {
        testPubishingSavesTopicState() // Initilize the state as TestTopic1.success
        Swafka.shared.publish(topic: TestTopic1.failure)
        let topic = Swafka.shared.getLastLog(of: TestTopic1.self)
        XCTAssertEqual(topic, TestTopic1.failure)
    }
    
    func testSubscription() {
        measure {
            var clousureHasRun = false
            Swafka.shared.subscribe(self, to: TestTopic1.self) { topic in
                clousureHasRun = true
            }
            Swafka.shared.publish(topic: TestTopic1.success)
            XCTAssertEqual(clousureHasRun, true)
        }
    }
    
    func testSubscriberGetsInitialState() {
        measure {
            Swafka.shared.publish(topic: TestTopic1.success)
            Swafka.shared.subscribe(self, to: TestTopic1.self) { topic in
                XCTAssertEqual(topic,TestTopic1.success)
            }
        }
    }
    
    func testSubscribeMultipleSubscribers() {
        var subcriber1ClosureHasRan = false
        var subcriber2ClosureHasRan = false
        var subcriber3ClosureHasRan = false
        var subcriber4ClosureHasRan = false
        var subcriber5ClosureHasRan = false
        
        let mySwafka = Swafka()
        
        mySwafka.subscribe(self, to: TestTopic1.self) { topic in
            subcriber1ClosureHasRan = true
        }
        mySwafka.subscribe(self, to: TestTopic1.self) { topic in
            subcriber2ClosureHasRan = true
        }
        mySwafka.subscribe(self, to: TestTopic1.self) { topic in
            subcriber3ClosureHasRan = true
        }
        mySwafka.subscribe(self, to: TestTopic1.self) { topic in
            subcriber4ClosureHasRan = true
        }
        mySwafka.subscribe(self, to: TestTopic1.self) { topic in
            subcriber5ClosureHasRan = true
        }
        let subscriberCount = mySwafka.getConsumersOf(topic: TestTopic1.self)?.count
        XCTAssertEqual(subscriberCount, 5)
        XCTAssertEqual(Swafka.shared.getConsumersOf(topic: TestTopic1.self)?.count, nil)
        measure {
            mySwafka.publish(topic: TestTopic1.success)
        }
        let allClosuresHaveRan = subcriber1ClosureHasRan && subcriber2ClosureHasRan && subcriber3ClosureHasRan && subcriber4ClosureHasRan && subcriber5ClosureHasRan
        XCTAssertEqual(allClosuresHaveRan, true)
    }
    
    static var allTests = [
        ("testSubscribeTimng", testSwafkaInitialization),
        ("Test Publishing Method", testPubishingSavesTopicState),
        ("Test Publishing Method", testPublishingUpdatesTopicState),
        ("Test Publishing Method", testSubscription),
        ("Test Publishing Method", testSubscriberGetsInitialState),
        ("Test Publishing Method", testSubscribeMultipleSubscribers)
    ]
}
