import SwiftUI

struct HeartButton: View {
    @Binding var isSet: Bool
    
    var body: some View {
        Button(action: {
            isSet.toggle()
        }) {
            Image(systemName: isSet ? "heart.fill" : "heart")
                .foregroundColor(isSet ? .red : .gray)
        }
    }
}

struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        HeartButton(isSet: .constant(false))
    }
}
