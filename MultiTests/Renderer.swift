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
    var pointPipelineState: MTLRenderPipelineState!
    var trianglePipelineState: MTLRenderPipelineState!
    var meshPipelineState: MTLRenderPipelineState!
    var timer: Float = 0
    var total_points: UInt32 = 50
    var showGrid: Bool = true
    var trainUniforms = Uniforms()
    var quadUniforms = Uniforms()
    
    // lazy = initialized only when it's first used
    lazy var quad: Quad = {
        Quad(device: Self.device, scale: 0.8)
    }()
    
    lazy var model: Model = {
        Model(device: Renderer.device, name: "train.usdz")
    }()
    
    
    init(metalView: MTKView, totalPoints: UInt32, showGrid: Bool) {
        self.total_points = totalPoints
        self.showGrid = showGrid
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
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        // create the pipeline state object
        
        // Creating pipeline states is relatively time-consuming
        // which is why you do it up-front
        // but switching pipeline states during frames is fast and efficient
        let trianglePipelineDescriptor = MTLRenderPipelineDescriptor()
        trianglePipelineDescriptor.vertexFunction = library?.makeFunction(name: "triangle_vertex_main")
        trianglePipelineDescriptor.fragmentFunction = fragmentFunction
        trianglePipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let triangleVertexDescriptor = MTLVertexDescriptor()
        
        // the position of each vertex
        triangleVertexDescriptor.attributes[0].format = .float3
        triangleVertexDescriptor.attributes[0].offset = 0
        triangleVertexDescriptor.attributes[0].bufferIndex = 0
        triangleVertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        // color part
        triangleVertexDescriptor.attributes[1].format = .float3
        triangleVertexDescriptor.attributes[1].offset = 0
        triangleVertexDescriptor.attributes[1].bufferIndex = 1
        triangleVertexDescriptor.layouts[1].stride = MemoryLayout<simd_float3>.stride
        
        trianglePipelineDescriptor.vertexDescriptor = triangleVertexDescriptor
        
        
        let pointPipelineDescriptor = MTLRenderPipelineDescriptor()
        pointPipelineDescriptor.vertexFunction = library?.makeFunction(name: "point_vertex_main")
        pointPipelineDescriptor.fragmentFunction = fragmentFunction
        pointPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        let meshPipelineDescriptor = MTLRenderPipelineDescriptor()
        meshPipelineDescriptor.vertexFunction = library?.makeFunction(name: "mesh_vertex_main")
        meshPipelineDescriptor.fragmentFunction = fragmentFunction
        meshPipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        meshPipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
        
        do {
            trianglePipelineState = try device.makeRenderPipelineState(descriptor: trianglePipelineDescriptor)
            pointPipelineState = try device.makeRenderPipelineState(descriptor: pointPipelineDescriptor)
            meshPipelineState = try device.makeRenderPipelineState(descriptor: meshPipelineDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.4, alpha: 1.0)
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        let aspect = Float(view.bounds.width) / Float(view.bounds.height)
        let projectionMatrix = float4x4(
            projectionFov: Float(45).degreesToRadians,
            near: 0.1,
            far: 100,
            aspect: aspect)
        trainUniforms.projectionMatrix = projectionMatrix
        quadUniforms.projectionMatrix = projectionMatrix
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {
            return
        }
        
        guard
            let commandBuffer = Self.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }

        timer += 0.01
        
        // When possible, use indexed rendering. With indexed rendering, you pass less data to the GPU
        // memory bandwidth is a major bottleneck
        
        // You can pass any data in an MTLBuffer to the GPU using setVertexBuffer(_:offset:index:)
        // If the data is less than 4KB -> pass a structure using setVertexBytes(_:length:index:)
        renderEncoder.setVertexBytes(&total_points, length: MemoryLayout<UInt32>.stride, index: 12)
        renderEncoder.setVertexBytes(&timer, length: MemoryLayout<Float>.stride, index: 11)
        
        quadUniforms.viewMatrix = float4x4(translation: [0, 0, 0]).inverse
        quad.position.x = -1
        quad.position.y = 1
        quad.position.z = 6
        quad.rotation.z = cos(timer)
        quadUniforms.modelMatrix = quad.transform.modelMatrix
        renderEncoder.setVertexBytes(&quadUniforms, length: MemoryLayout<Uniforms>.stride, index: 14)
        renderEncoder.setVertexBuffer(quad.vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(quad.colorBuffer, offset: 0, index: 1)
        
        // Draw quad
        renderEncoder.setRenderPipelineState(trianglePipelineState)
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: quad.indices.count, indexType: .uint16, indexBuffer: quad.indexBuffer, indexBufferOffset: 0)
        
        // Draw points
        renderEncoder.setRenderPipelineState(pointPipelineState)
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: Int(total_points), instanceCount: 1)
        
        // Draw mesh
        renderEncoder.setRenderPipelineState(meshPipelineState)
        renderEncoder.setTriangleFillMode(.lines)
        trainUniforms.viewMatrix = float4x4(translation: [0, 0, -3]).inverse
        model.position.y = -0.6
        model.rotation.y = sin(timer)
        trainUniforms.modelMatrix = model.transform.modelMatrix
        renderEncoder.setVertexBytes(&trainUniforms, length: MemoryLayout<Uniforms>.stride, index: 14)
        
        model.render(encoder: renderEncoder)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
