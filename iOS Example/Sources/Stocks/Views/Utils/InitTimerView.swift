import SwiftUI
import Swafka

struct TimerView: View {
    
    @EnvironmentObject var vm: StockMarketDataViewModel
    
    var text: String
    
    @Binding var secondsElapsed: Double


    var body: some View {
        HStack {
            Text(text)
                .font(.headline)
            Spacer()
            Text(String(format: "%.1f", secondsElapsed) + " sec")
            }
        .padding(10)
    }
        
}



