import Foundation
import Swafka
import Network

final class TopicData: ObservableObject {
    @Published var stocks: [Stock] = load("stockData.json")
    @Published var connectedState = false
    
    init() {
        Swafka.subscribe( self as AnyObject , to: Connectivity.self, thread: .main) { topic in
            switch topic {
            case .connected:
                print("CONNNECTIVITY SUBSCRIBER 1 Completion: Connected ")
                self.connectedState = true
            case .notConnected:
                print("CONNNECTIVITY SUBSCRIBER 1 Completion: Not Connected")
                self.connectedState = false
            }
        }
        
        
        Swafka.subscribe( self as AnyObject , to: ManipulatePrice.self, thread: .main) { topic in
            switch topic {
            case .increase:
                print("ManipulatePrice SUBSCRIBER 1 Completion: increase ")
                let count = self.stocks.count
                for index in 0...count-1 {
                    self.stocks[index].price -= 1
                }
            case .decrease:
                print("ManipulatePrice SUBSCRIBER 1 Completion: Not decrease")
                let count = self.stocks.count
                for index in 0...count-1 {
                    self.stocks[index].price -= 1
                }
            }
        }
        
        Swafka.subscribe( self as AnyObject, to: StockTopic.self, thread: .main) { topic in
            if let indexOfStockToUpdate = self.stocks.firstIndex(where: {$0.name == topic.name }) {
                self.stocks[indexOfStockToUpdate].price = topic.price
            }
        }
        
        URLSession.shared
    }
}

public func initStockUpdates(context: AnyObject) {
    
    var price = 123.00
    
    _ =  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
        Swafka.publish(topic: StockTopic.init(name: "VTL", price: price))
        price += 1
    }
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

