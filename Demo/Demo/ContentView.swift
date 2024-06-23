//
//  ContentView.swift
//  Demo
//
//  Created by Daniel Pourhadi on 6/23/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollViewWithStatusBarBlur {
            VStack {
                ForEach(0..<100) { _ in
                    HStack {
                        ForEach(0..<3) { _ in
                            VStack {
                                Image(systemName: "globe")
                                    .imageScale(.large)
                                Text("Hello, world!")
                            }
                        }
                    }
                }
            }
            .environment(\.colorScheme, colorScheme)
        }
    }
}


#Preview {
    ContentView()
}
