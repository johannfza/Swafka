//
//  iOS_ExampleApp.swift
//  iOS Example
//
//  Created by Johann Fong on Jul 17, 2021.
//

import SwiftUI

@main
struct iOS_ExampleApp: App {
    
    @StateObject private var topicData = TopicData()
    
    init() {
        initConnectivityTopic()
        initStockUpdates(context: self as AnyObject)
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(topicData)
        }
    }
}
