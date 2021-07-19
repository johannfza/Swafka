
public struct Stock: Hashable, Codable, Identifiable {
    
    public var id: Int
    public var name: String
    public var price: Double
    public var inWatchlist: Bool
    
    public init(id: Int, name: String, price: Double, inWatchlist: Bool) {
        self.id = id
        self.name = name
        self.price = price
        self.inWatchlist = inWatchlist
    }
    

}


