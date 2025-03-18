//
//  Quad.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 25/02/2025.
//

import MetalKit

struct Vertex {
    var x: Float
    var y: Float
    var z: Float
}

struct Quad: Transformable {
    var transform = Transform()

    var vertices: [Vertex] = [
        Vertex(x: -1, y:  1, z: 0.5),
        Vertex(x:  1, y:  1, z: 0.5),
        Vertex(x: -1, y: -1, z: 0.5),
        Vertex(x:  1, y: -1, z: 0.5)
    ]
    var indices: [UInt16] = [
        0, 3, 2,
        0, 1, 3
    ]
    var colors: [simd_float3] = [
        [0.6, 0, 0],
        [1, 0, 0],
        [0.95, 0, 0],
        [0.7, 0, 0]
    ]
    
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let colorBuffer: MTLBuffer
    
    init(device: MTLDevice, scale: Float = 1) {
        vertices = vertices.map {
            Vertex(x: $0.x * scale, y: $0.y * scale, z: $0.z * scale)
        }
        guard let vertexBuffer = device.makeBuffer(
            bytes: &vertices,
            length: MemoryLayout<Vertex>.stride * vertices.count,
            options: []) else {
            fatalError("Unable to create quad vertex buffer")
        }
        self.vertexBuffer = vertexBuffer
        
        guard let indexBuffer = device.makeBuffer(bytes: &indices, length: MemoryLayout<UInt16>.stride * indices.count, options: []) else {
            fatalError("Unable to create quad index buffer")
        }
        self.indexBuffer = indexBuffer
        
        guard let colorBuffer = device.makeBuffer(bytes: &colors, length: MemoryLayout<simd_float3>.stride * colors.count, options: []) else {
            fatalError("Unable to create quad color buffer")
        }
        self.colorBuffer = colorBuffer
    }
}
