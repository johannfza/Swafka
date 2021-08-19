import Foundation

struct Consumer<T> {
    
    typealias Payload = T
    
    weak var context: AnyObject?
    let thread: SThread?
    let completion: (Payload) -> ()
}
