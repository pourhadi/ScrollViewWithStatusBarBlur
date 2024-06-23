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
            VStack(spacing: 12) {
                Text("Scroll View")
                    .font(.headline)
                Text("with status bar blur")
                    .font(.subheadline)
                HStack(spacing: 12) {
                    Color.red
                        .frame(height: 50)
                    Color.green
                        .frame(height: 50)
                    Color.blue
                        .frame(height: 50)
                    Color.yellow
                        .frame(height: 50)
                }
                
                ForEach(0..<50) { _ in
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
        }
    }
}


#Preview {
    ContentView()
}
