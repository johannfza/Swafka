import Foundation

public enum CompletionThread {
    case main
    case background(queue: DispatchQueue?)
    
    var queue: DispatchQueue {
        switch self {
        case .main:
            return .main
        case .background(let queue):
            return queue ?? .global()
        }
    }
}
