//
//  ContentView.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 02/02/2025.
//

import MetalKit
import ModelIO
import SwiftUI

struct MetalView: NSViewRepresentable {
    let device: MTLDevice!
    let commandQueue: MTLCommandQueue!
    let pipelineState: MTLRenderPipelineState!
    let mesh: MTKMesh!

    init() {
        device = MTLCreateSystemDefaultDevice()!
        
        let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
        let view = MTKView(frame: frame, device: device)
        view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)

        let allocator = MTKMeshBufferAllocator(device: device)
//        let mdlMesh = MDLMesh(
//            sphereWithExtent: [0.75, 0.75, 0.75],
//            segments: [100, 100],
//            inwardNormals: false,
//            geometryType: .triangles,
//            allocator: allocator)
        
        let mdlMesh = MDLMesh(
          coneWithExtent: [1, 1, 1],
          segments: [10, 10],
          inwardNormals: false,
          cap: true,
          geometryType: .triangles,
          allocator: allocator)

        
        
        mesh = try! MTKMesh(mesh: mdlMesh, device: device)
      
        
        commandQueue = device.makeCommandQueue()!
        
        
        guard let library = device.makeDefaultLibrary() else {
            fatalError("No .metal files in the Xcode project")
        }

        let vertexFunction = library.makeFunction(name: "vertex_main")!
        let fragmentFunction = library.makeFunction(name: "fragment_main")!
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        view.device = device
        view.delegate = context.coordinator
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MTKViewDelegate {
        let parent: MetalView

        init(_ parent: MetalView) {
            self.parent = parent
            super.init()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else { return }

            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].storeAction = .store
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: 0, green: 0, blue: 0, alpha: 1)

            let commandBuffer = parent.commandQueue.makeCommandBuffer()!
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(
                descriptor: renderPassDescriptor)!

            renderEncoder.setRenderPipelineState(parent.pipelineState)

            renderEncoder.setVertexBuffer(parent.mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
            renderEncoder.setTriangleFillMode(.lines)
            
            guard let submesh = parent.mesh.submeshes.first else {
              fatalError()
            }
            renderEncoder.drawIndexedPrimitives(
              type: .triangle,
              indexCount: submesh.indexCount,
              indexType: submesh.indexType,
              indexBuffer: submesh.indexBuffer.buffer,
              indexBufferOffset: 0)

            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

struct ContentView: View {
    var body: some View {
        MetalView()
            .frame(width: 600, height: 600)
    }
}
