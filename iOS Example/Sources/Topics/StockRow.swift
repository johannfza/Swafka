import SwiftUI

struct StockRow: View {
    @EnvironmentObject var topicData: TopicData
    
    var stock: Stock
    
    var stockIndex: Int {
            topicData.stocks.firstIndex(where: { $0.id == stock.id })!
        }


    var body: some View {
        HStack {
            Text(stock.name).padding()
            HeartButton(isSet: $topicData.stocks[stockIndex].inWatchlist )
            Spacer()
            Text(String(stock.price)).padding()

        }
    }
}

struct StockRow_Previews: PreviewProvider {
    
    static var topicData = TopicData()
    
    static var previews: some View {
        Group {
            StockRow(stock: (topicData.stocks[0])).environmentObject(topicData)
            StockRow(stock: (topicData.stocks[1])).environmentObject(topicData)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
