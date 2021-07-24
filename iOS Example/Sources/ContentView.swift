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
            VStack {
                Text("Top Stocks")
                    .font(.title)
            }
            .padding()
            Spacer()
        }
        .padding()
//        ConnectionStatusView(isConnected: $topicData.connectedState)
        LoadingTypeView(loadingType: $topicData.reloadType)
        APITimerView(secondsElapsed: $topicData.secondsElapsed)
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

