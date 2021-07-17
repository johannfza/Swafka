//
//  ContentView.swift
//  iOS Example
//
//  Created by Johann Fong on Jul 17, 2021.
//

import SwiftUI
import Swafka

struct SwiftUISwafka: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return Swafka()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct ContentView: View {
    var body: some View {
        VStack(alignment: .center) {
            SwiftUISwafka()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
