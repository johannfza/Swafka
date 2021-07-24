import Foundation

public struct DWGetReferentialQuoteRsDTO: Codable {
    
    public var symbol: String
//    public var bid: Double
    public var ask: Double
    public var lastTrade: Double
    public var change: Double?
    public var open: Double
    public var high: Double
    public var low: Double
    public var close: Double
    public var priorClose: Double
//    public var volume: Int
//    public var marketCondition: String?
//    public var dataProvider: String?

    
}
