import Foundation

internal class Cluster {
    
    // MARK: - Properties
    private var brokers = [String: Any]()
    
    // MARK: - Queue
    private let queue = DispatchQueue(label: "cluster_queue_barrier", qos: .background, attributes: .concurrent)
    
    func subscribe<T: Topicable>(_ context: AnyObject, thread: Thread? = nil, getInitialState: Bool = true, completion: @escaping (T) -> ()) {
        queue.async(flags: .barrier) {
            let topicName = String(describing: T.self)
            print(topicName)
            guard let broker = self.brokers[topicName] as? Broker<T> else {
                let broker = Broker<T>()
                broker.subscribe(context, thread: thread, getInitialState: getInitialState, completion: completion)
                self.brokers[topicName] = broker
                return
            }
            broker.subscribe(context, thread: thread, getInitialState: getInitialState, completion: completion)
        }
    }

    func publish<T>(topic: T) where T : Topicable {
        queue.sync {
            let topicName = String(describing: T.self)
            print(topicName)
            guard let broker = brokers[topicName] as? Broker<T> else {
                brokers[topicName] = Broker(firstEntry: topic)
                return
            }
            broker.publish(topic: topic)
        }
    }

    func unsubscribe<T>(_ context: AnyObject, from: T.Type) where T : Topicable {
        queue.sync {
            guard let broker = brokers[String(describing: T.self)] as? Broker<T> else {
                return
            }
            broker.unsubscribe(context)
        }
    }

    func getLastLog<T>(of topic: T.Type) -> T? where T : Topicable {
        queue.sync {
            guard let broker = brokers[String(describing: T.self)] as? Broker<T> else {
                return nil
            }
            return broker.getLastLog()
        }
    }
    
    func subscribeOnActive<T>(_ context: AnyObject, thread: Thread? = nil, completion: @escaping (T.Type) -> ()) where T : Topicable {
        queue.async(flags: .barrier) {
            let topicName = String(describing: T.self)
            print(topicName)
            guard let broker = self.brokers[topicName] as? Broker<T> else {
                let broker = Broker<T>()
                broker.subscribeOnActive(context, thread: thread, completion: completion)
                self.brokers[topicName] = broker
                return
            }
            broker.subscribeOnActive(context, thread: thread, completion: completion)
        }
    }
    
    func subscribeOnInactive<T>(_ context: AnyObject, thread: Thread? = nil, completion: @escaping (T.Type) -> ()) where T : Topicable {
        queue.async(flags: .barrier) {
            let topicName = String(describing: T.self)
            print(topicName)
            guard let broker = self.brokers[topicName] as? Broker<T> else {
                let broker = Broker<T>()
                broker.subscribeOnInactive(context, thread: thread, completion: completion)
                self.brokers[topicName] = broker
                return
            }
            broker.subscribeOnInactive(context, thread: thread, completion: completion)
        }
    }
}
