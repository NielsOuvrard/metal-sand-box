//
//  Shoot.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 31/03/2025.
//

import MetalKit

struct LineVertex {
    var positionStart: SIMD3<Float>
    var positionEnd: SIMD3<Float>
}

enum Shoot {
    static let linePipelineState: MTLRenderPipelineState = {
        let library = Renderer.library
        let vertexFunction = library?.makeFunction(name: "vertex_primitives")
        let fragmentFunction = library?.makeFunction(name: "fragment_primitives_line")
        let psoDescriptor = MTLRenderPipelineDescriptor()
        psoDescriptor.vertexFunction = vertexFunction
        psoDescriptor.fragmentFunction = fragmentFunction
        psoDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        psoDescriptor.depthAttachmentPixelFormat = .depth32Float
        let pipelineState: MTLRenderPipelineState
        do {
            pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: psoDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        return pipelineState
    }()
    
    static let pointPipelineState: MTLRenderPipelineState = {
        let library = Renderer.library
        let vertexFunction = library?.makeFunction(name: "vertex_primitives")
        let fragmentFunction = library?.makeFunction(name: "fragment_primitives_point")
        let psoDescriptor = MTLRenderPipelineDescriptor()
        psoDescriptor.vertexFunction = vertexFunction
        psoDescriptor.fragmentFunction = fragmentFunction
        psoDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        psoDescriptor.depthAttachmentPixelFormat = .depth32Float
        let pipelineState: MTLRenderPipelineState
        do {
            pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: psoDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        return pipelineState
    }()
    
    static func draw(shoots: [LineVertex], encoder: MTLRenderCommandEncoder, uniforms: Uniforms) {
        for shoot in shoots {
            debugDrawLine(
                renderEncoder: encoder,
                uniforms: uniforms,
                line: shoot,
                color: float3(1, 0, 0))
        }
    }
    
    static func debugDrawPoint()
    {
    }
    
    static func debugDrawDirection()
    {
    }
    
    static func debugDrawLine(
        renderEncoder: MTLRenderCommandEncoder,
        uniforms: Uniforms,
        line: LineVertex,
        color: float3
    ) {
        var vertices: [float3] = []
        vertices.append(line.positionStart)
        vertices.append(line.positionEnd)

        let buffer = Renderer.device.makeBuffer(bytes: &vertices, length: MemoryLayout<float3>.stride * vertices.count, options: [])
        
        var uniforms = uniforms
        uniforms.modelMatrix = .identity
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        
        var lightColor = color
        renderEncoder.setFragmentBytes(&lightColor, length: MemoryLayout<float3>.stride, index: 1)
        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        
        // render line
        renderEncoder.setRenderPipelineState(linePipelineState)
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertices.count)
        
        // render starting point
        renderEncoder.setRenderPipelineState(pointPipelineState)
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 1)
    }
}
