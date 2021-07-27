import SwiftUI
import Swafka
import Network


struct ToggleView: View {

    public var text: String
    @Binding var isSet: Bool
    
    var body: some View {
        Toggle(isOn: $isSet) {
            Text(text)
        }
        .padding(10)
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
