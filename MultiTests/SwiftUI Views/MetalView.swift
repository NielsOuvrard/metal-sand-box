//
//  MetalView.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 03/02/2025.
//


import SwiftUI
import MetalKit

struct MetalView: View {
    @State private var metalView = MTKView()
    @State private var renderer: Renderer?
    
    @Binding var totalPoints: UInt32
    @Binding var showGrid: Bool
    
    var body: some View {
        MetalViewRepresentable(metalView: $metalView)
            .onAppear {
                renderer = Renderer(metalView: metalView, totalPoints: totalPoints, showGrid: showGrid)
            }
            .onChange(of: totalPoints) { _, newValue in
                renderer = Renderer(metalView: metalView, totalPoints: newValue, showGrid: showGrid)
            }
            .onChange(of: showGrid) { _, newValue in
                renderer = Renderer(metalView: metalView, totalPoints: totalPoints, showGrid: newValue)
            }
    }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalViewRepresentable: ViewRepresentable {
    @Binding var metalView: MTKView
    
#if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        metalView
    }
    func updateNSView(_ uiView: NSViewType, context: Context) {
        updateMetalView()
    }
#elseif os(iOS)
    func makeUIView(context: Context) -> MTKView {
        metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        updateMetalView()
    }
#endif
    
    func updateMetalView() {
    }
}

//#Preview {
//  VStack {
//      MetalView(totalPoints:50, showGrid:true)
//    Text("Metal View")
//  }
//}
