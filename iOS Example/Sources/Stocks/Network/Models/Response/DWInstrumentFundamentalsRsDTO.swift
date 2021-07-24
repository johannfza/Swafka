public struct DWInstrumentFundamentalsRsDTO: Codable {
    
    public var symbol: String
    public var reutersPrimaryRic: String
    public var name: String
    public var description: String
    public var sector: String?
    public var longOnly: Bool
    public var orderSizeMax: Double
    public var orderSizeMin: Double
    public var orderSizeStep: Double
    public var exchangeNickelSpread: Bool
    public var close: Double
    public var descriptionChinese: String?
    public var fundamentalDataModel: FundamentalDataModel?
    public var id: String
    public var type: String?
    public var exchange: String?
    public var url: String?
    public var status: InstrumentStatus
    public var closePrior: Double
    public var image: String?
    
}


public struct FundamentalDataModel: Codable {
    
    public var instrumentID: String
    public var symbol: String
    public var companyName: String?
    public var openPrice: Double?
    public var bidPrice: Double?
    public var askPrice: Double?
    public var lowPrice: Double?
    public var highPrice: Double?
    public var fiftyTwoWeekLowPrice: Double?
    public var fiftyTwoWeekHighPrice: Double?
    public var cumulativeVolume: Double?
    public var marketCap: Double?
    public var peRatio: Double?
    public var dividendYield: Double?
    public var earningsPerShare: Double?
    public var dividend: Double?
    public var sharesOutstanding: Int?
    public var timeLastUpdate: String?
    public var bookValuePerShare: String?
    public var cashFlowPerShare: String?
    public var operatingIncome: String?
    public var pbRatio: String?
    public var volumeMovingAverage10Day: Double?
    public var volumeMovingAverage25Day: Double?
    public var volumeMovingAverage50Day: Double?
    public var priceMovingAverage50Day: Double?
    public var priceMovingAverage150Day: Double?
    public var priceMovingAverage200Day: Double?
    public var roe: String?
}
