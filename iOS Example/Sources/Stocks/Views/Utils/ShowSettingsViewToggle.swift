import Foundation
import SwiftUI

struct ShowSettingsViewToggle: View {
    
    @Binding var showSettings: Bool

    
    var body: some View {
        Image(systemName: showSettings ? "list.bullet.indent" : "list.bullet")
            .onTapGesture(perform: {
            showSettings = !showSettings
        })
    }
}
