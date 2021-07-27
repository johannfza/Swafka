import Swafka

public struct PollingInterval: Topicable {
    public var interval: Double
}

public struct InitTimer: Topicable {
    public var secondsElapsed: Double
}
