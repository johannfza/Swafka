import SwiftUI
import Swafka

struct StockList: View {
    
    @EnvironmentObject var topicData: StockMarketData
    
    @State private var showWatchlistOnly = false
    
    var filteredStocks: [StockListItem] {
        topicData.stocks.filter { stock in
            (!showWatchlistOnly || stock.inWatchlist)
        }
    }
    
    var body: some View {
        List {
            Toggle(isOn: $showWatchlistOnly) {
                Text("Watchlist only")
            }
//            HStack {
//                Text("Symbol").font(.headline)
//                Spacer()
//                Text("Price").font(.headline)
//            }
            .padding()
            
            if filteredStocks.count > 0 {
                ForEach(filteredStocks) { stock in
                    StockRow(stock: stock)
                    
                }
            } else {
                VStack {
                    ProgressView()
                }
            }
        }
    }
}

struct StockList_Previews: PreviewProvider {
    static var previews: some View {
        StockList().environmentObject(StockMarketData())
    }
}


struct MockDataStreamButton: View {
    
    @Binding var stocks: [StockListItem]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
//                    Swafka.shared.publish(topic: ManipulatePrice.increase)
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
//                    Swafka.shared.publish(topic: ManipulatePrice.decrease)
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
