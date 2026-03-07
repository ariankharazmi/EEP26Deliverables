//
//  ContentView.swift
//  JawbreakTest1
//
//  Created by Arian Kharazmi on 3/7/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "face.smiling")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Face")
                .font(.title)
                .fontWeight(.medium)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
