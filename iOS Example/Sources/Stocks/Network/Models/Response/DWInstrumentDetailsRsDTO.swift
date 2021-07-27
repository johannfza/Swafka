internal struct DWInstumentDetailsRsDTO: Codable {
    
    public var symbol: String
    public var reutersPrimaryRic: String?
    public var name: String
    public var description: String?
    public var sector: String?
    public var longOnly: Bool?
    public var orderSizeMax: Int?
    public var orderSizeMin: Double?
    public var orderSizeStep: Double?
    public var exchangeNickelSpread: Bool?
    public var close: Double
    public var descriptionChinese: String?
    public var id: String
    public var type: String
    public var exchange: String?
    public var url: String?
    public var status: InstrumentStatus
    public var closePrior: Double
    public var image: String?
    public var ISIN: String?
    
}
