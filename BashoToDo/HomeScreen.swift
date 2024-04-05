//
//  ContentView.swift
//  BashoToDo
//
//  Created by hoge on 2024/03/25.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
