import SwiftUI

struct APITimerView: View {
    
    @Binding var secondsElapsed: Double
    
    
    var body: some View {
        HStack {
            Text("Initlialization Time")
                .font(.headline)
            Spacer()
            Text(String(format: "%.2f", secondsElapsed) + " sec")
        }
        .padding()
    }
}



