import SwiftUI
import Swafka
import Network


struct ConnectionStatusView: View {

    @Binding var isConnected: Bool
    
    var body: some View {
        HStack() {
            Text(isConnected ? "Connected" : "Not Connected")
                .font(.headline)
            Spacer()
            Image(systemName: isConnected ? "circle.fill" : "circle")
                .foregroundColor(isConnected ? .green : .gray)
        }
        .padding()
    }
}



struct ConnectionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConnectionStatusView(isConnected: .constant(true))
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
