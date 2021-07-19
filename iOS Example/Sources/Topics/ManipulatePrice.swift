import Foundation
import Swafka

public enum ManipulatePrice: Topicable {
    case increase
    case decrease
}
