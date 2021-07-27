//
//  ContentView.swift
//  iOS Example
//
//  Created by Johann Fong on Jul 17, 2021.
//

import SwiftUI
import Swafka


struct TitleView: View {
    
    @EnvironmentObject var vm: StockMarketDataViewModel
    
    @State private var showSettings: Bool = true
    
    var body: some View {
        HStack {
            Text("Top Stocks")
                .font(.title)
                .padding(10)
            VStack(alignment: .trailing) {
                ShowSettingsViewToggle(showSettings: $showSettings)
            }
        }
        if showSettings {
            ToggleView(text: "Do Polling", isSet: $vm.isMarketOpen)
            ToggleView(text: "Use Delayed", isSet: $vm.useDelayed)
            ToggleView(text: "Use Cached Stock List", isSet: $vm.useCachedStockList)
            LoadingTypeView(loadingType: $vm.loadingType)
            PollingIntervalView(interval: $vm.pollingInterval)
            TimerView(text: "Initilization Timer", secondsElapsed: $vm.secondsElapsed)
        }
        if vm.isMarketOpen {
            TimerView(text: "Since Last Price Update", secondsElapsed: $vm.secondsElapsedSinceLastUpdate)
        }
        SearchBarView(searchText: $vm.searchText)
    }
}


struct ContentView: View {
    var body: some View {
        VStack {
            TitleView()
            Spacer()
            StockList()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(StockMarketDataViewModel())
    }
}

