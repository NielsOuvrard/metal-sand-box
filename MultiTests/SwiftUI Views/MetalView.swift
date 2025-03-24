//
//  MetalView.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 03/02/2025.
//


import SwiftUI
import MetalKit


extension Color {
    func toFloat4() -> simd_float4 {
        let components = self.cgColor?.components ?? [0, 0, 0, 1]
        return simd_float4(Float(components[0]), Float(components[1]), Float(components[2]), Float(components[3]))
    }
}

struct MetalView: View {
    @State private var metalView = MTKView()
    @State private var renderer: Renderer?
    
    @Binding var rightJoystickPosition: CGPoint
    @Binding var leftJoystickPosition: CGPoint
    @Binding var color: Color
    
    var body: some View {
        MetalViewRepresentable(metalView: $metalView)
            .onAppear {
                renderer = Renderer(metalView: metalView)
            }
            .onChange(of: rightJoystickPosition) { _, newValue in
                renderer?.updateRightJoystickPosition(newValue, view: metalView)
            }
            .onChange(of: leftJoystickPosition) { _, newValue in
                renderer?.updateLeftJoystickPosition(newValue, view: metalView)
            }
            .onChange(of: color) { _, newValue in
                renderer?.updateColor(newValue.toFloat4())
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
