internal struct DWListAllInstrumentRSDTO: Codable, HasSymbol {
    
    public var symbol: String
    public var name: String
    public var id: String
    public var status: InstrumentStatus
    
}
