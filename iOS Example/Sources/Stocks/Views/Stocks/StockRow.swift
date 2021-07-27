import SwiftUI

struct StockRow: View {
    
    @EnvironmentObject var topicData: StockMarketDataViewModel
    
    var stock: StockListItem
    
//    var stockIndex: Int {
//        topicData.stocks.firstIndex(where: { $0.id == stock.id })!
//    }
    @State var animate: Bool = true

    @State var animationColor = Color.red

    func animatePriceChange() {
        animate.toggle()
        withAnimation(Animation.easeInOut(duration: 0.8).repeatCount(1, autoreverses: true)) {
            animate.toggle()
        }
    }
    
    var body: some View {
        HStack {
            if let image = stock.image {
                CircleLogoView(urlString: image)
                    .padding(.trailing, 5)
            } else {
                CircleLogoView()
                    .padding(.trailing, 5)

            }
            VStack(alignment: .leading) {
                Text(stock.name)
                    .font(.headline)
                Text(stock.symbol)
                    .font(.footnote)
            }

            Spacer()
            VStack(alignment: .trailing) {
                Text("\(stock.getPrice()) USD")
                    .font(.headline)
                Text("\(stock.getPriceChange())(\(stock.getPriceChangePerentage()))%")
                    .font(.footnote)
                    .foregroundColor(stock.priceChange > 0.00 ? Color.green : Color.red)
            }
            .shadow(color: animate ? .clear : animationColor, radius: 2, x: 3, y: 3)
            .padding(.trailing, 5)
            .onChange(of: stock.ask) { [stock] value in
                if stock.ask > value {
                    self.animationColor = .red
                } else {
                    self.animationColor = .green
                }
                animatePriceChange()
            }

        }
    }
}

struct StockRow_Previews: PreviewProvider {
    
    @State static var topicData = StockMarketDataViewModel()
    
    static var previews: some View {
        Group {
            StockRow(stock: topicData.stocks[0]).environmentObject(topicData)
            StockRow(stock: topicData.stocks[1]).environmentObject(topicData)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
