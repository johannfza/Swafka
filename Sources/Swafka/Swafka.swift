import Foundation

public final class Swafka  {
    
    public init() {}
    
    private let queue = DispatchQueue(label: "activte_notification_barrier", qos: .background, attributes: .concurrent)
    
    private var cluster = Cluster()
    
    public func subscribe<T: Topicable>(_ context: AnyObject, thread: CompletionThread? = nil, getInitialState: Bool = true, completion: @escaping (T) -> ()) {
        cluster.subscribe(context, thread: thread, getInitialState: getInitialState, completion: completion)
    }
    
    public func subscribe<T: Topicable>(_ context: AnyObject, to topic: T.Type, thread: CompletionThread? = nil, getInitialState: Bool = true, completion: @escaping (T) -> ()) {
        cluster.subscribe(context, thread: thread, getInitialState: getInitialState, completion: completion)
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
    
    public func subscribeOnActive<T>(_ context: AnyObject, thread: CompletionThread? = nil, completion: @escaping (T.Type) -> ()) where T : Topicable {
        cluster.subscribeOnActive(context, thread: thread, completion: completion)
    }
    
    public func subscribeOnInactive<T>(_ context: AnyObject, thread: CompletionThread? = nil, completion: @escaping (T.Type) -> ()) where T : Topicable {
        cluster.subscribeOnInactive(context, thread: thread, completion: completion)
    }
}
