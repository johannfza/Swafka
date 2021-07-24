import SwiftUI

struct LoadingTypeView: View {
    
    @Binding var loadingType: APIType

    
    var body: some View {
        HStack {
            Text("LoadingType")
                .font(.headline)
            Spacer()
            Menu(String(describing: loadingType)) {
                Button("Use Fundamentals API") {
                    print("Use Fundamentals API")
                }
                Button("Use Quotes API") {
                    print("Use Quotes API")
                }
                Button("Use Cached Symbols") {
                    print("Use Cached Symbols")
                }
            }
        }
        .padding()
    }
}
