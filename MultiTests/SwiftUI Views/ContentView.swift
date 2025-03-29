//
//  ContentView.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 02/02/2025.
//

import MetalKit
import ModelIO
import SwiftUI
import GameController

let originalColor = Color(red: 0.8, green: 0.8, blue: 0.8)
let size: CGFloat = 400

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            MetalView()
                .border(Color.black, width: 2)
        }
    }
}

#Preview {
    ContentView()
}
