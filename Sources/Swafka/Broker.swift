import Foundation

class Broker<T: Topicable> {
    
    // MARK: - Types
    typealias Topic = T
    
    // MARK: - Properties
    private var log = [Topic]()
    
    /// Consumers
    private var consumers = [Consumer<Topic>]() {
        didSet {
            if oldValue.count == 0 && consumers.count == 1 {
                runCompletionBlockForOnInactiveConsumers()
            }
            if oldValue.count == 1 && consumers.count == 0 {
                runCompletionBlockForOnActiveConsumers()
            }
        }
    }
    private var onActiveConsumers = [Consumer<Topic.Type>]()
    private var onInactiveConsumers = [Consumer<Topic.Type>]()
    
    /// Queues
    private let queue = DispatchQueue(label: "broker_publisher_consumer_queue", qos: .background, attributes: .concurrent)
    private let onActiveQueue = DispatchQueue(label: "broker_onactive_queue", qos: .background, attributes: .concurrent)
    private let onInactiveQueue = DispatchQueue(label: "broker_onactive_queue", qos: .background, attributes: .concurrent)
    
    // MARK: - Initlizers
    init() {}
    
    
    /// Initialise a `Broker` and appends a first `Topic` into the `log`
    /// - Parameter firstEntry: First entry of the `log`
    init(firstEntry: Topic) {
        log.append(firstEntry)
    }
    
    // MARK: - Private Functions
    
    /// Gets the latest appende value of the `Log`
    /// - Returns: Latest entry of the `Log`
    func getLastLog() -> Topic? {
        queue.sync {
            return self.log.last
        }
    }
    
    /// Appends a new entry into the `log`
    /// - Parameter topic: Topic that is appended to the`log`
    private func updateLog(_ topic: Topic) {
        queue.async(flags: .barrier) {
            self.log.append(topic)
        }
    }
    
    /// Runs the `completion` block of all the `Consumers` that are in `onInactiveConsumers`
    private func runCompletionBlockForOnInactiveConsumers() {
        onActiveQueue.sync {
            onActiveConsumers.forEach {
                let consumer = $0
                if let completionThread = consumer.thread?.queue {
                    completionThread.async {
                        consumer.completion(Topic.self)
                    }
                } else {
                    CompletionThread.main.queue.async {
                        consumer.completion(Topic.self)
                    }
                }
            }
        }
    }
    
    /// Runs the `completion` block of all the `Consumers` that are in `onActiveConsumers`
    private func runCompletionBlockForOnActiveConsumers() {
        onInactiveQueue.sync {
            onInactiveConsumers.forEach {
                let consumer = $0
                if let completionThread = consumer.thread?.queue {
                    completionThread.async {
                        consumer.completion(Topic.self)
                    }
                } else {
                    CompletionThread.main.queue.async {
                        consumer.completion(Topic.self)
                    }
                }
            }
        }
    }
    
    /// Runs the `completion` block of all the `Consumers` that are in `consumers`
    private func runCompletionBlockForConsumers(topic: Topic) {
        
    }

    
    // MARK: - Functions
    
    /// Subscribes a consumer to the `Broker`'s `Topic`
    /// - Parameters:
    ///   - context: a reference to the  consumer `self`
    ///   - thread: which thread to run the completion on
    ///   - getInitialState: is the case where the `log` has an entry, should the completion run immediately with the latest `log` entry
    ///   - completion: the completion block of the `Consumer`
    func subscribe(_ context: AnyObject, thread: CompletionThread? = nil, getInitialState: Bool? = true, completion: @escaping (Topic) -> ()) {
        queue.async(flags: .barrier) {
            self.consumers.append(Consumer(context: context, thread: thread, completion: completion))
        }
        queue.sync {
            if getInitialState ?? false {
                guard let lastState = log.last else {
                    return
                }
                if let completionThread = thread?.queue {
                    completionThread.async {
                        completion(lastState)
                    }
                } else {
                    CompletionThread.main.queue.async {
                        completion(lastState)
                    }
                }
            }
        }
    }
    
    
    /// Unsubscribes a consumer to the `Broker`'s `Topic`
    /// - Parameters:
    ///   - context: a reference to the  consumer `self`
    func unsubscribe(_ context: AnyObject) {
        queue.async(flags: .barrier) {
            self.consumers = self.consumers.filter { $0.context! !== context }
        }
    }
    
    /// Publishes a new `Topic` payload to all `completion` block of all the `Consumers` that are in the `consumers` array
    func publish(topic: Topic) {
        updateLog(topic)
        queue.async(flags: .barrier) {
            self.consumers = self.consumers.filter { $0.context != nil } // Remove nil observers
            
        }
        queue.sync {
            consumers.forEach {
                let consumer = $0
                if let completionThread = consumer.thread?.queue {
                    completionThread.async {
                        consumer.completion(topic)
                    }
                } else {
                    CompletionThread.main.queue.async {
                        consumer.completion(topic)
                    }
                }
            }
        }
    }
    
    /// Subscribes to a notification of when the `consumer` count increase from 0 to 1
    /// - Parameters:
    ///   - context: a reference to the  consumer `self`
    ///   - thread: which thread to run the completion on
    ///   - completion: the completion block of the `Consumer`
    func subscribeOnActive(_ context: AnyObject, thread: CompletionThread? = nil, completion: @escaping (Topic.Type) -> ()) {
        onActiveQueue.async(flags: .barrier) {
            self.onActiveConsumers.append(Consumer(context: context, thread: thread, completion: completion))
        }
    }
    
    /// Subscribes to a notification of when the `consumer` count increase from 1 to 0
    /// - Parameters:
    ///   - context: a reference to the  consumer `self`
    ///   - thread: which thread to run the completion on
    ///   - completion: the completion block of the `Consumer`
    func subscribeOnInactive(_ context: AnyObject, thread: CompletionThread? = .main, completion: @escaping (Topic.Type) -> ()) {
        onInactiveQueue.async(flags: .barrier) {
            self.onInactiveConsumers.append(Consumer(context: context, thread: thread, completion: completion))
        }
    }
}
