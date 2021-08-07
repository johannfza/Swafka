import Foundation

struct Consumer<T> {
    
    typealias Payload = T
    
    weak var context: AnyObject?
    let thread: Thread?
    let completion: (Payload) -> ()
}
