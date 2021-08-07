import Foundation

public enum Thread {
    case main
    case background(queue: DispatchQueue?)
    
    internal var queue: DispatchQueue {
        switch self {
        case .main:
            return .main
        case .background(let queue):
            return queue ?? .global()
        }
    }
}
