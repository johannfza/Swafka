import SwiftUI
import Swafka
import Network


struct UseCachedStockListView: View {

    @Binding var useCachedList: Bool
    
    var body: some View {
        Toggle(isOn: $useCachedList) {
            Text("Use Cached StockList")
        }
        .padding()
    }
}



struct UseCachedStockListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConnectionStatusView(isConnected: .constant(true))
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
