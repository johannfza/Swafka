//
//  ContentView.swift
//  iOS Example
//
//  Created by Johann Fong on Jul 17, 2021.
//

import SwiftUI
import Swafka


struct TitleView: View {
    
    @EnvironmentObject var topicData: StockMarketData
    
    var body: some View {
        HStack {
            CircleImage()
            VStack(alignment: .leading) {
                Text("Swafka Demo")
                    .font(.title)
                Text("Swafka's stock list!")
                    .font(.subheadline)
            }
            .padding()
            Spacer()
        }
        .padding()
        ConnectionStatusView(isConnected: $topicData.connectedState)
    }
}

struct CircleImage: View {
    var body: some View {
        Image("turtlerock")
            .resizable()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray, lineWidth: 4))
            .shadow(radius: 7)
    }
}

struct ContentView: View {
    var body: some View {
        VStack(alignment: .center) {
            TitleView()
            Spacer()
            StockList()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(StockMarketData())
    }
}


