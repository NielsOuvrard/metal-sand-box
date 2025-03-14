//
//  Renderer.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 03/02/2025.
//

import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!

    var mesh: MTKMesh!
    //var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var timer: Float = 0
    var total_points: UInt32 = 50

    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("GPU not available")
        }
        Self.device = device
        Self.commandQueue = commandQueue
        metalView.device = device

        // create the shader function library
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")

        // create the pipeline state object

        // Creating pipeline states is relatively time-consuming
        // which is why you do it up-front
        // but switching pipeline states during frames is fast and efficient
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {
            return
        }
        
        guard
            let commandBuffer = Self.commandQueue.makeCommandBuffer()
        else {
            return
        }
        
        // lazy = initialized only when it's first used
        lazy var quad: Quad = {
            Quad(device: Self.device, scale: 0.8)
        }()
    
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 0.81, alpha: 1)
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        timer += 0.005

        renderEncoder.setVertexBytes(&total_points, length: MemoryLayout<UInt32>.stride, index: 0)
        renderEncoder.setVertexBytes(&timer, length: MemoryLayout<Float>.stride, index: 11)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: Int(total_points), instanceCount: 1)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
