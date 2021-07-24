import Foundation
import Swafka
import Network
import Combine

fileprivate let noOfStocksToDisplay = 100

final class StockMarketData: ObservableObject {
    @Published var stocks: [StockListItem] = [StockListItem]()
    
    private let cached100Symbols = load("symbols.json") as [String]
    
    @Published var connectedState = false
    
    @Published var useCachedStockList = true
    
    @Published var isMarketOpen = true
      
    @Published var secondsElapsed = 0.0
    var timer = Timer()

    var cancellables: [AnyCancellable]? = nil
    
    var loadingType: ListLoadingType = .fundamentals
    
    private var credentials = DWCredentials(
        appTypeID: 4,
        username: "bo.ocbc.api",
        password: "passw0rd",
        appKey: "3754992a-54ef-443f-afd0-0d655d6f34c1"
    )
    
    private func getAllStockSymbols(stocks: [HasSymbol]) -> [String] {
        if self.useCachedStockList {
            return cached100Symbols
        }
        var symbols = [String]()
        stocks.forEach { stock in
            symbols.append(stock.symbol)
        }
        return symbols
    }
    
    init() {
        
        Swafka.shared.subscribe( self as AnyObject, to: ListLoadingType.self, thread: .main) { topic in
            print("\(topic.rawValue)")
            self.loadingType = topic
            self.reloadList()
        }
    
        
        Swafka.shared.subscribe( self as AnyObject, to: UpdatePriceTopic.self, thread: .main) { topic in
            if let indexOfStockToUpdate = self.stocks.firstIndex(where: {$0.symbol == topic.symbol }) {
                self.stocks[indexOfStockToUpdate].ask = topic.ask
                self.stocks[indexOfStockToUpdate].open = topic.open
            }
        }
    
        authenticateSession() { [self] result in
            switch result {
            case .success:
                startAPITimer()
                print("authenticateSession Succesfully Created!")
                if useCachedStockList && loadingType == .fundamentals {
                    loadStocksUsingFundamentalsAPI(symbols: cached100Symbols) { _ in
                        updateStockPrices(symbols: cached100Symbols) { _ in
                            stopAPITimer()
                        }
                    }
                } else {
                    listAllInstruments() { listAllInstrumentsResponse in
                        switch listAllInstrumentsResponse {
                        case .success(let instruments):
                            switch loadingType {
                            case .fundamentals:
                                loadStocksUsingFundamentalsAPI(instruments: instruments) { _ in
                                    updateStockPrices(symbols: cached100Symbols) { _ in
                                        stopAPITimer()
                                    }
                                }
                            case .quotes:
                                loadStocksUsingQuotesAPI(instruments: instruments) { _ in
                                    stopAPITimer()
                                }
                            }
                        case .failure:
                            print("Error listAllInstruments")
                        }
                    }
                }
            case .failure:
                print("Error")
            }
        }
    }
    
    func reloadList() {
        DispatchQueue.main.async {
            self.stocks.removeAll()
        }
        authenticateSession() { [self] result in
            switch result {
            case .success:
                startAPITimer()
                print("authenticateSession Succesfully Created!")
                if useCachedStockList && loadingType == .fundamentals {
                    loadStocksUsingFundamentalsAPI(symbols: cached100Symbols) { _ in
                        updateStockPrices(symbols: cached100Symbols) { _ in
                            stopAPITimer()
                        }
                    }
                } else {
                    listAllInstruments() { listAllInstrumentsResponse in
                        switch listAllInstrumentsResponse {
                        case .success(let instruments):
                            switch loadingType {
                            case .fundamentals:
                                loadStocksUsingFundamentalsAPI(instruments: instruments) { _ in
                                    updateStockPrices(symbols: cached100Symbols) { _ in
                                        stopAPITimer()
                                    }
                                }
                            case .quotes:
                                loadStocksUsingQuotesAPI(instruments: instruments) { _ in
                                    stopAPITimer()
                                }
                            }
                        case .failure:
                            print("Error listAllInstruments")
                        }
                    }
                }
            case .failure:
                print("Error")
            }
        }
    }
    
    func startAPITimer() {
        DispatchQueue.main.async {
            self.secondsElapsed = 0.0
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                self.secondsElapsed += 0.01
            }
        }
    }
    
    func stopAPITimer() {
        DispatchQueue.main.async {
            self.timer.invalidate()
        }
    }
    
    private func loadStocksUsingFundamentalsAPI(symbols: [String], completion: @escaping  (Bool) -> Void) {
        
        let group = DispatchGroup()
        
        var nStockList = [StockListItem]()

        for symbol in symbols {
            group.enter()
            getInstrumentFundamentals(symbol: symbol) { response in
                switch response {
                case .success(let instrument):
                    guard let fundamentalDataModel =  instrument.fundamentalDataModel else {
                        break
                    }
                    nStockList.append(StockListItem(
                        id: instrument.id,
                        name: instrument.name,
                        symbol: instrument.symbol,
                        status: instrument.status,
                        ask: fundamentalDataModel.askPrice ?? 0.00,
                        open: fundamentalDataModel.openPrice ?? 0.00,
                        close: instrument.close,
                        priorClose: instrument.closePrior,
                        inWatchlist: Bool.random(),
                        image: instrument.image)
                    )
                case .failure:
                    print("Error")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("Retrieved \(nStockList.count)/\(symbols.count) with fufficient details")
            self.stocks = nStockList.sorted(by: {lhs, rhs in  return lhs.name > rhs.name})
            completion(true)
        }
        
    }

    
    
    private func loadStocksUsingFundamentalsAPI(instruments: [DWListAllInstrumentRSDTO], completion: @escaping  (Bool) -> Void) {
        
        let symbols = Array(self.getAllStockSymbols(stocks: instruments)[...noOfStocksToDisplay])
        
        return loadStocksUsingFundamentalsAPI(symbols: symbols, completion: completion)
    }
    
    private func loadStocksUsingQuotesAPI(instruments: [DWListAllInstrumentRSDTO], completion: @escaping  (Bool) -> Void) {
        self.getStockPrices(symbols: Array(self.getAllStockSymbols(stocks: instruments)[...noOfStocksToDisplay])) { getStockPricesResponse in
            switch getStockPricesResponse {
            case .success(let quotes):
                var nStockList = [StockListItem]()
                for quote in quotes {
                    if let instrument = instruments.first(where: { $0.symbol == quote.symbol}) {
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
                    self.stocks = nStockList.sorted(by: {lhs, rhs in  return lhs.name > rhs.name})
                }
            case .failure:
                print("Error getStockPrices")
            }
        }
        completion(true)
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
                completion(.success(instruments))
            } catch let error {
                print(String(describing: error))
            }
        })
        task.resume()
    }
    
    private func getInstrumentDetails(symbol: String, completion: @escaping (Result<DWInstumentDetailsRsDTO, Error>) -> Void) {
        let request = getDWURLRequest(path: "instruments/\(symbol)", httpMethod: .get)
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
                let instrumentDetails = try decoder.decode(DWInstumentDetailsRsDTO.self, from: data)
                print(String(describing: instrumentDetails))
//                completion(.success(instruments))
            } catch let error {
                print(String(describing: error))
            }
        })
        task.resume()
    }
    
    private func getInstrumentFundamentals(symbol: String, completion: @escaping (Result<DWInstrumentFundamentalsRsDTO, Error>) -> Void) {
        let queryOptions = URLQueryItem(name: "options", value: "Fundamentals")
        let request = getDWURLRequest(path: "instruments/\(symbol)/", queryItems: [queryOptions], httpMethod: .get)
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
                let instrumentFundamentals = try decoder.decode(DWInstrumentFundamentalsRsDTO.self, from: data)
                print(String(describing: instrumentFundamentals))
                completion(.success(instrumentFundamentals))
            } catch let error {
                print(String(describing: error))
            }
        })
        task.resume()
    }
    
    func getStockPrices(symbols: [String], completion: @escaping (Result<[DWGetReferentialQuoteRsDTO], Error>) -> Void) {
        let symbolsStr = symbols.joined(separator: ",")
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
    
    func updateStockPrices(symbols: [String], completion: @escaping (Bool) -> Void) {
        let symbolsStr = symbols.joined(separator: ",")
        print("symbolsStr", symbolsStr)
        let queryItemSymbols = URLQueryItem(name: "symbols", value: symbolsStr)
        let request = getDWURLRequest(path: "quotes", queryItems: [queryItemSymbols] , httpMethod: .get)
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
                let stockQuotes = try decoder.decode([DWGetReferentialQuoteRsDTO].self, from: data)
                for stock in stockQuotes {
                    print(stock)
                    Swafka.shared.publish(topic: UpdatePriceTopic(symbol: stock.symbol, ask: stock.ask, open: stock.open))
                }
                completion(true)
            } catch let error {
                print(String(describing: error))
                completion(false)
            }
        })
        
        task.resume()
        
    }
    
    
    
    
    func getStockDetails() {
        
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
                
                for stock in stockQuotes {
                    print(stock)
                    Swafka.shared.publish(topic: UpdatePriceTopic(symbol: stock.symbol, ask: stock.ask, open: stock.open))
                }
                if self.isMarketOpen {
                    self.updatePrice()
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
        
    }
}
