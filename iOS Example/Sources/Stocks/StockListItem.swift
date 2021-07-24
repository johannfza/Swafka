
public struct StockListItem: Hashable, Codable, Identifiable {
    
    public var id: String
    public var name: String
    public var symbol: String
    public var status: InstrumentStatus
    public var ask: Double
    public var open: Double
    public var close: Double
    public var priorClose: Double
    public var inWatchlist: Bool = false
    
    public var priceChangePercent: Double {
        // If market is open, open param will not be 0
        if open != 0 {
            return ((ask - open) / open) * 100
        }
        if priorClose != 0 {
            return ((ask - priorClose) / priorClose) * 100
        }
        return 0.00
    }
    
    public var priceChange: Double {
        // If market is open, open param will not be 0
        if open != 0 {
            return ask - open
        }
        return ask - priorClose
    }
    
    func getPriceChange() -> String {
        String(format: "%.2f", priceChange)
    }
    func getPriceChangePerentage() -> String {
        String(format: "%.2f", priceChangePercent)
    }
    
    func getPrice() -> String {
        String(format: "%.2f", ask)

    }
}


public enum InstrumentStatus: String, Codable {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
    case closeOnly = "CLOSE_ONLY"
    case halted = "HALTED"
}
