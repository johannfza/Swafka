import Swafka

public struct UpdatePriceTopic: Topicable {
    public var symbol: String
    public var ask: Double
    public var open: Double
}
