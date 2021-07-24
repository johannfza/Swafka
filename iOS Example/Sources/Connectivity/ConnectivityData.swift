import Network
import Swafka

public enum Connectivity: Topicable {
    case connected
    case notConnected
}

public enum ListLoadingType: String, Topicable {
    case fundamentals = "Fundamentals API"
    case quotes = "Referencial Quotes API"
}

public func initConnectivityTopic() {
    let monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { path in
        switch path.status {
        case .satisfied:
            Swafka.shared.publish(topic: Connectivity.connected)
        case .requiresConnection, .unsatisfied:
            Swafka.shared.publish(topic: Connectivity.notConnected)
        @unknown default:
            Swafka.shared.publish(topic: Connectivity.notConnected)
        }
    }
    let queue = DispatchQueue(label: "network_monitor")
    monitor.start(queue: queue)
}
