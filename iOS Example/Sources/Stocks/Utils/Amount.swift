import Foundation

public enum Currency: String {
    case sgd = "SGD"
    case eur = "EUR"
    case usd = "USD"
}

public struct Amount {
    
    var value: Decimal
    var currency: Currency
    
    public init(value: Decimal, currency: Currency) {
        self.value = value
        self.currency = currency
    }
    
    public func getAmount() -> String {
        return "\(getValue()) \(currency.rawValue)"
    }
    
    public func getCurrrency() -> String {
        return currency.rawValue
    }
    
    public func getValue() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.currencyCode = currency.rawValue
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = ""
        guard let value = currencyFormatter.string(from: NSDecimalNumber(decimal: value)) else {
            return ""
        }
        return value
    }
}
