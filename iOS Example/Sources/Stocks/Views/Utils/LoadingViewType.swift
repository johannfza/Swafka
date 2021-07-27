import SwiftUI
import Swafka

struct LoadingTypeView: View {
    
    @Binding var loadingType: ListLoadingType

    
    var body: some View {
        HStack {
            Text("Initialization Type")
                .font(.headline)
            Spacer()
            Menu(loadingType.rawValue) {
                Button("Use Fundamentals API") {
                    Swafka.shared.publish(topic: ListLoadingType.fundamentals)
                }  
                Button("Use Quotes API") {
                    Swafka.shared.publish(topic: ListLoadingType.quotes)
                }
            }
        }
        .padding(10)
    }
}
