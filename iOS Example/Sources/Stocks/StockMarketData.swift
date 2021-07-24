import Foundation
import Swafka
import Network

fileprivate let noOfStocksToDisplay = 100

final class StockMarketData: ObservableObject {
    @Published var stocks: [StockListItem] = [StockListItem]()

    @Published var connectedState = false
    
    private var credentials = DWCredentials(
        appTypeID: 4,
        username: "bo.ocbc.api",
        password: "passw0rd",
        appKey: "3754992a-54ef-443f-afd0-0d655d6f34c1"
    )
    
    private func getAllStockSymbols(stocks: [DWListAllInstrumentRSDTO]) -> [String] {
        var symbols = [String]()
        stocks.forEach { stock in
            symbols.append(stock.symbol)
        }
        return symbols
    }
    
    init() {
        Swafka.shared.subscribe( self as AnyObject , to: Connectivity.self, thread: .main) { topic in
            switch topic {
            case .connected:
                print("CONNNECTIVITY SUBSCRIBER 1 Completion: Connected ")
                self.connectedState = true
            case .notConnected:
                print("CONNNECTIVITY SUBSCRIBER 1 Completion: Not Connected")
                self.connectedState = false
            }
        }
        authenticateSession() { result in
            
            // check market status
            switch result {
            case .success:
                print("authenticateSession Succesfully Created!")
                self.listAllInstruments() { listAllInstrumentsResponse in
                    switch listAllInstrumentsResponse {
                    case .success(let instrumentList):
                        self.getStockPrices(count: noOfStocksToDisplay, symbols: self.getAllStockSymbols(stocks: instrumentList)) { getStockPricesResponse in
                            switch getStockPricesResponse {
                            case .success(let quotes):
                                print(quotes)
//                                print(stockList)
                                
                            var nStockList = [StockListItem]()
                            for quote in quotes {
                                if let instrument = instrumentList.first(where: { $0.symbol == quote.symbol}) {
                                    nStockList.append(StockListItem(
                                        id: instrument.id,
                                        name: instrument.name,
                                        symbol: instrument.symbol,
                                        status: instrument.status,
                                        ask: quote.ask,
                                        open: quote.open,
                                        close: quote.close,
                                        priorClose: quote.priorClose,
                                        inWatchlist: Bool.random()
                                    )
                                    )
                                }
                            }
                            DispatchQueue.main.async {
                                self.stocks = nStockList
                            }
                            case .failure:
                                print("Error getStockPrices")
                            }
                        }
                    case .failure:
                        print("Error listAllInstruments")
                    }
                    
                }
//                self.updatePrice()
            case .failure:
                print("Error")
            }
        }
//        updatePrice()
        
        Swafka.shared.subscribe( self as AnyObject, to: StockQuoteTopic.self, thread: .main) { topic in
            if let indexOfStockToUpdate = self.stocks.firstIndex(where: {$0.symbol == topic.symbol }) {
                self.stocks[indexOfStockToUpdate].ask = topic.lastTrade
                self.stocks[indexOfStockToUpdate].open = topic.open
            }
        }
        

        
        //        _ =  Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
        //            let randomInt = Int.random(in: 0..<self.stocks.count - 1)
        //            let randomBool = Bool.random()
        //            if randomBool {
        //                Swafka.shared.publish(topic: StockTopic.init(name: self.stocks[randomInt].name, price: self.stocks[randomInt].price + 1 ))
        //            } else {
        //                Swafka.shared.publish(topic: StockTopic.init(name: self.stocks[randomInt].name, price: self.stocks[randomInt].price - 1 ))
        //
        //            }
        //        }
        
    }
    
    private func listAllInstruments(completion: @escaping (Result<[DWListAllInstrumentRSDTO], Error>) -> Void) {
        let request = getDWURLRequest(path: "instruments", httpMethod: .get)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let instruments = try decoder.decode([DWListAllInstrumentRSDTO].self, from: data)
//                var stockListItems = [StockListItem]()
//                reponseBody.forEach { instrument in
//                    stockListItems.append(
//                        StockListItem(
//                            id: instrument.id,
//                            name: instrument.name,
//                            symbol: instrument.symbol,
//                            status: instrument.status
//                        )
//                    )
//                }
                completion(.success(instruments))
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func getStockPrices(count: Int, symbols: [String], completion: @escaping (Result<[DWGetReferentialQuoteRsDTO], Error>) -> Void) {
        let symbolsSlice = symbols[...count]
        let symbolsStr = symbolsSlice.joined(separator: ",")
        print("symbolsStr", symbolsStr)
        let queryItemSymbols = URLQueryItem(name: "symbols", value: symbolsStr)
//                let queryItemSymbols = URLQueryItem(name: "symbols", value: "TEST%20z,JAMF,STIP,SHY,FLWS,ARCHS,ARCHC,VCVC")

        let request = getDWURLRequest(path: "quotes", queryItems: [queryItemSymbols] , httpMethod: .get)
        let session = URLSession.shared
        print(request.url)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let stockQuotes = try decoder.decode([DWGetReferentialQuoteRsDTO].self, from: data)
                completion(.success(stockQuotes))
            } catch let error {
                print(String(describing: error))
            }
        })
        
        task.resume()
        
    }
    
    
    
    func initStockData() {
        
    }
    
    func authenticateSession(completion: @escaping (Result<Bool, Error>) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "bo-api.drivewealth.io"
        components.path = "/back-office/auth"
        let requestBody = try? JSONEncoder().encode(
            DWAuthenticationRqDTO(
                username: credentials.username,
                password: credentials.password,
                appTypeID: 4))
        
        //create the session object
        let session = URLSession.shared
        
        // HEADER
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue(credentials.appKey, forHTTPHeaderField: "dw-client-app-key")
        request.httpBody = requestBody
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                print(data)
                let authenticationResponse = try decoder.decode(DWAuthenticationRsDTO.self, from: data)
                self.credentials.session = DWSession(
                    userID: authenticationResponse.userID,
                    authToken: authenticationResponse.authToken
                )
                completion(.success(true))

            } catch let error {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
        
    }
    
    
    
    func getDWURLRequest(path: String, queryItems: [URLQueryItem]? = nil, httpMethod: HTTPMethod) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "bo-api.drivewealth.io"
        components.path = "/back-office/\(path)"
//        let queryItemSymbols = URLQueryItem(name: "symbols", value: "TSLA,AAPL,NFLX,OTLY,MSFT")
        if queryItems != nil {
            components.queryItems = queryItems
        }
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: components.url!)
        request.httpMethod = httpMethod.rawValue
        
        guard let userID = credentials.session?.userID, let authToken = credentials.session?.authToken else {
            fatalError("no session credentials")
        }
        
        request.setValue(credentials.appKey, forHTTPHeaderField:"dw-client-app-key")
        request.setValue(authToken, forHTTPHeaderField: "dw-auth-token")
        request.setValue(userID, forHTTPHeaderField: "dw-customer-user-id")
        
        return request
    }
    

    
    func updatePrice() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "bo-api.drivewealth.io"
        components.path = "/back-office/quotes"
        let queryItemSymbols = URLQueryItem(name: "symbols", value: "TSLA,AAPL,NFLX,OTLY,MSFT")
        components.queryItems = [queryItemSymbols]
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        guard let userID = credentials.session?.userID, let authToken = credentials.session?.authToken else {
            fatalError("no session credentials")
        }
        
        request.setValue(credentials.appKey, forHTTPHeaderField:"dw-client-app-key")
        request.setValue(authToken, forHTTPHeaderField: "dw-auth-token")
        request.setValue(userID, forHTTPHeaderField: "dw-customer-user-id")
        
        //create the session object
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                print(data)
                let stockQuotes = try decoder.decode([DWGetReferentialQuoteRsDTO].self, from: data)
                
                for quotes in stockQuotes {
//                    Swafka.shared.publish(
//                        topic: StockQuoteTopic(
//                        symbol: quotes.symbol,
//                        bid: quotes.bid,
//                        ask: quotes.ask,
//                        lastTrade: quotes.lastTrade,
//                        change: quotes.change,
//                        open: quotes.open,
//                        high: quotes.high,
//                        low: quotes.low,
//                        close: quotes.close,
//                        priorClose: quotes.priorClose,
//                        volume: quotes.volume ?? 0.00,
//                        marketCondition: quotes.marketCondition ?? "",
//                        dataProvider: quotes.dataProvider ?? ""
//                        )
//                    )
                }
//                print(stockQuotes)
                self.updatePrice()

            } catch let error {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
        
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



private struct DWCredentials {
    
    public var appTypeID: Int
    public var username: String
    public var password: String
    public var appKey: String
    public var session: DWSession?
}


private struct DWSession {
    
    public var userID: String
    public var authToken: String
}

private struct DWAuthenticationRqDTO: Codable {
    
    public var username: String
    public var password: String
    public var appTypeID: Int
    
}


private struct DWAuthenticationRsDTO: Codable {
    
    public var authToken: String
    public var userID: String
    
}


public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

private struct DWListAllInstrumentRSDTO: Codable {
    
    public var symbol: String
    public var name: String
    public var id: String
    public var status: InstrumentStatus
    
}
