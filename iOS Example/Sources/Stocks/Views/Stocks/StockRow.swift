import SwiftUI

struct StockRow: View {
    @EnvironmentObject var topicData: StockMarketData
    
    var stock: StockListItem
    
    var stockIndex: Int {
        topicData.stocks.firstIndex(where: { $0.id == stock.id })!
    }


    var body: some View {
        HStack {
            if let image = stock.image {
                CircleLogoView(urlString: image).padding()
            } else {
                CircleLogoView().padding()
            }
            VStack(alignment: .leading) {
                Text(stock.name).font(.headline)
                Text(stock.symbol).font(.footnote)
            }
            HeartButton(isSet: $topicData.stocks[stockIndex].inWatchlist)
                .buttonStyle(BorderlessButtonStyle())
            Spacer()
            VStack(alignment: .trailing) {

                Text("\(stock.getPrice()) USD")
                Text("\(stock.getPriceChange())(\(stock.getPriceChangePerentage()))%")
                    .font(.footnote)
                    .foregroundColor(stock.priceChange > 0.00 ? Color.green : Color.red)
                
            }
            .padding()
        }
    }
}

struct StockRow_Previews: PreviewProvider {
    
    static var topicData = StockMarketData()
    
    static var previews: some View {
        Group {
            StockRow(stock: (topicData.stocks[0])).environmentObject(topicData)
            StockRow(stock: (topicData.stocks[1])).environmentObject(topicData)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
