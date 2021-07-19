import SwiftUI
import Swafka

struct StockList: View {
    
    @EnvironmentObject var topicData: TopicData
    
    @State private var showWatchlistOnly = false
    
    var filteredStocks: [Stock] {
        topicData.stocks.filter { stock in
            (!showWatchlistOnly || stock.inWatchlist)
        }
    }
    
    var body: some View {
        List {
            MockDataStreamButton(stocks: $topicData.stocks)
            
            Toggle(isOn: $showWatchlistOnly) {
                Text("Watchlist only")
            }
            HStack {
                Text("Symbol").font(.headline)
                Spacer()
                Text("Price").font(.headline)
            }
            .padding()
            
            ForEach(filteredStocks) { stock in
                StockRow(stock: stock)
                
            }
        }
    }
}

struct StockList_Previews: PreviewProvider {
    static var previews: some View {
        StockList().environmentObject(TopicData())
    }
}


struct MockDataStreamButton: View {
    
    @Binding var stocks: [Stock]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    Swafka.publish(topic: ManipulatePrice.increase)
                }) {
                    Text("Increase Price")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                        .border(Color.green, width: 3)
                        .cornerRadius(5)
                }.buttonStyle(BorderlessButtonStyle())
                
                
                Spacer()
                Button(action: {
                    Swafka.publish(topic: ManipulatePrice.decrease)
                }) {
                    Text("Decrease Price")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .border(Color.red, width: 3)
                        .cornerRadius(5)
                }.buttonStyle(BorderlessButtonStyle())
                
            }
        }
    }
}
