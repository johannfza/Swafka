//
//  CircleLogoView.swift
//  iOS Example
//
//  Created by Johann Fong  on 24/7/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct CircleLogoView: View {
    
    var urlString: String = "https://image.shutterstock.com/z/stock-vector-logo-design-business-finance-stock-exchange-market-chart-vector-abstract-symbol-design-elements-1735749296.jpg"
    
    var body: some View {
        WebImage(url: URL(string: urlString))
            .resizable()
            .placeholder(Image("twinlake"))
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .shadow(radius: 5)
    }
}

struct CircleLogoView_Previews: PreviewProvider {
    static var previews: some View {
        CircleLogoView()
    }
}
