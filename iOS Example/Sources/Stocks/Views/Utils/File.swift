import SwiftUI

struct UpdatePriceTimerView: View {
    
    var text: String
    
    @Binding var secondsElapsed: Double
    
    var state: InitTimerTopic = .start
    
//    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

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
