//
//  __PROJECT_NAME__.swift
//  __PROJECT_NAME__
//
//  Created by Johann Fong on Jul 17, 2021.
//  Copyright © 2021 Johann Fong. All rights reserved.
//
import Foundation

public protocol Topicable: Hashable {
    
}

public struct Consumer {
    weak var context: AnyObject?
    let thread: Thread?
    let completion: Any
}

public enum Thread {
    case main
    case background(queue: DispatchQueue?)
    
    fileprivate var queue: DispatchQueue {
        switch self {
        case .main:
            return .main
        case .background(let queue):
            return queue ?? .global()
        }
    }
}

public final class Swafka  {
    
    public static let shared: Swafka = {
        let instance = Swafka()
        return instance
    }()
    
    private var cluster = Cluster()
    
    public func subscribe<T: Topicable>(_ context: AnyObject, thread: Thread? = nil, getInitialState: Bool = true, completion: @escaping (T) -> ()) {
        cluster.subscribe(context, thread: thread, getInitialState: getInitialState, completion: completion)
    }
    
    public func subscribe<T: Topicable>(_ context: AnyObject, to topic: T.Type, thread: Thread? = nil, getInitialState: Bool = true, completion: @escaping (T) -> ()) {
        cluster.subscribe(context, thread: thread, getInitialState:  getInitialState, completion: completion)
    }
    
    public func publish<T: Topicable>(topic: T) {
        cluster.publish(topic: topic)
    }
    
    public func unsubscribe<T: Topicable>(_ context: AnyObject, from topic: T.Type) {
        cluster.unsubscribe(context, from: topic)
    }
    
    public func getLastLog<T: Topicable>(of topic: T.Type) -> T? {
        return cluster.getLastLog(of: topic)
    }
    
    public func getConsumersOf<T: Topicable>(topic: T.Type) -> [Consumer]? {
        return cluster.getConsumersOf(topic: topic)
    }
    
}

internal class Cluster {
    
    private var brokers = [String: Broker]()
    
//    private var database = [String: Any]()
    
    private let queue = DispatchQueue(label: "cluster_queue_barrier", qos: .background, attributes: .concurrent)
    
    public func subscribe<T: Topicable>(_ context: AnyObject, thread: Thread? = nil, getInitialState: Bool = true, completion: @escaping (T) -> ()) {
        queue.async(flags: .barrier) {
            let topicName = String(describing: T.self)
            
//            let initialState = getInitialState ? self.database[topicName] as? T : nil
            guard let broker = self.brokers[topicName] else {
                let broker = Broker()
                broker.subscribe(context, thread: thread, getInitialState: getInitialState, completion: completion)
                self.brokers[topicName] = broker
                return
            }
            broker.subscribe(context, thread: thread, getInitialState: getInitialState, completion: completion)
        }
    }
    
    
    public func publish<T: Topicable>(topic: T) {
        queue.sync {
            guard let broker = brokers[String(describing: T.self)] else {
                brokers[String(describing: T.self)] = Broker(firstEntry: topic)
                return
            }
            broker.publish(topic: topic)
        }
    }
    
    public func unsubscribe<T: Topicable>(_ context: AnyObject, from: T.Type) {
        queue.sync {
            guard let broker = brokers[String(describing: T.self)] else {
                return
            }
            broker.unsubscribe(context)
        }
    }
    
    public func getLastLog<T: Topicable>(of topic: T.Type) -> T? {
        queue.sync {
            return brokers[String(describing: T.self)]?.getLastLog()
        }
    }
    
    public func getBroker<T: Topicable>(of topic: T.Type) -> Broker? {
        queue.sync {
            return brokers[String(describing: T.self)] ?? nil
        }
    }
    
    public func getConsumersOf<T: Topicable>(topic: T.Type) -> [Consumer]? {
        queue.sync {
            return brokers[String(describing: T.self)]?.getConsumers() ?? nil
        }
    }
    
}

internal class Broker {
    
    convenience init(firstEntry: Any) {
        self.init()
        self.log.append(firstEntry)
    }
    
    internal var log: [Any] = []
    
    private let queue = DispatchQueue(label: "broker_queue_barrier", qos: .background, attributes: .concurrent)
    
    private let defaultQueue = DispatchQueue(label: "default_completion", qos: .background, attributes: .concurrent)
    
    private var consumers = [Consumer]()
    
    internal func getConsumers() -> [Consumer] {
        queue.sync {
            return self.consumers
        }
    }
    
    public func subscribe<T: Topicable>(_ context: AnyObject, thread: Thread? = nil, getInitialState: Bool? = true, completion: @escaping (T) -> ()) {
        queue.async(flags: .barrier) {
            self.consumers.append(Consumer(context: context, thread: thread, completion: completion))
            print(self.consumers)
        }
        queue.sync {
            if getInitialState ?? false {
                guard let lastState = log.last as? T else {
                    return
                }
                
                
                if let completionThread = thread?.queue {
                    completionThread.async {
                        completion(lastState)
                    }
                } else {
                    completion(lastState)
                    
                }
            }
        }
    }
    
    public func publish<T: Topicable>(topic: T) {
        updateLog(topic)
        queue.async(flags: .barrier) {
            self.consumers = self.consumers.filter { $0.context != nil } // Remove nil observers
            
        }
        queue.sync {
            consumers.forEach {
                if let completion = $0.completion as? (T) -> () {
                    if let completionThread = $0.thread?.queue {
                        completionThread.async {
                            completion(topic)
                        }
                    } else {
                        completion(topic)

                    }
                }
            }
        }
    }
    
    public func unsubscribe(_ context: AnyObject) {
        queue.async(flags: .barrier) {
            self.consumers = self.consumers.filter { $0.context! !== context }
        }
    }
    
    private func updateLog<T: Topicable>(_ topic: T) {
        queue.async(flags: .barrier) {
            self.log.append(topic)
        }
    }
    
    public func getLastLog<T: Topicable>() -> T? {
        queue.sync {
            return self.log.last as? T
        }
    }
}
