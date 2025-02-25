//
//  ContentView.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 02/02/2025.
//

import MetalKit
import ModelIO
import SwiftUI

struct ContentView: View {
    var body: some View {
        MetalView()
            .frame(width: 600, height: 600)
    }
}


// You do have the option not to use a vertex
// descriptor and just send an array of vertices in an MTLBuffer
