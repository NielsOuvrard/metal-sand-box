//
//  ContentView.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 02/02/2025.
//

import MetalKit
import ModelIO
import SwiftUI

let originalColor = Color(red: 0.8, green: 0.8, blue: 0.8)
let size: CGFloat = 400

struct ContentView: View {
    @State private var showGrid = true
    @State private var totalPoints: UInt32 = 50
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                MetalView(totalPoints: $totalPoints, showGrid: $showGrid)
                    .border(Color.black, width: 2)
                if showGrid {
                    Grid()
                }
            }
            .frame(width: size, height: size)
            ZStack(alignment: .top) {
                //Key()
                Toggle("Show Grid", isOn: $showGrid)
                    .padding(.leading, 250)
            }
            Slider(value: Binding(
                get: { Double(totalPoints) },
                set: { totalPoints = UInt32($0) }
            ), in: 1...100, step: 1)
            .padding()
            Text("Total Points: \(totalPoints)")
                .padding(.leading, 10)
        }
        .padding()
    }
}

struct Key: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Rectangle()
                    .foregroundColor(originalColor)
                    .frame(width: 20, height: 20)
                Text("Original triangle")
            }
            HStack {
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                Text("Transformed triangle")
            }
        }
        .padding(0)
    }
}

struct Grid: View {
    var cellSize: CGFloat = size / 20
    var body: some View {
        ZStack {
            HStack {
                ForEach(0..<Int(cellSize), id: \.self) { _ in
                    Spacer()
                    Divider()
                }
            }
            VStack {
                ForEach(0..<Int(cellSize), id: \.self) { _ in
                    Spacer()
                    Divider()
                }
            }
            Rectangle()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            Rectangle()
                .frame(width: 1)
                .frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}


// You do have the option not to use a vertex
// descriptor and just send an array of vertices in an MTLBuffer
