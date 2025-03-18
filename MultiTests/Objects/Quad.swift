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
        Vertex(x: -0.5, y:  0.5, z:  0.5), // Front top-left
        Vertex(x:  0.5, y:  0.5, z:  0.5), // Front top-right
        Vertex(x: -0.5, y: -0.5, z:  0.5), // Front bottom-left
        Vertex(x:  0.5, y: -0.5, z:  0.5), // Front bottom-right
        Vertex(x: -0.5, y:  0.5, z: -0.5), // Back top-left
        Vertex(x:  0.5, y:  0.5, z: -0.5), // Back top-right
        Vertex(x: -0.5, y: -0.5, z: -0.5), // Back bottom-left
        Vertex(x:  0.5, y: -0.5, z: -0.5)  // Back bottom-right
    ]

    var indices: [UInt16] = [
        // Front face
        0, 1, 2,
        1, 3, 2,
        // Back face
        4, 6, 5,
        5, 6, 7,
        // Left face
        0, 2, 4,
        4, 2, 6,
        // Right face
        1, 5, 3,
        5, 7, 3,
        // Top face
        0, 4, 1,
        1, 4, 5,
        // Bottom face
        2, 3, 6,
        6, 3, 7
    ]

    var colors: [simd_float3] = [
        [1, 0, 0], // Red
        [0, 1, 0], // Green
        [0, 0, 1], // Blue
        [1, 1, 0], // Yellow
        [1, 0, 1], // Magenta
        [0, 1, 1], // Cyan
        [0.5, 0.5, 0.5], // Gray
        [1, 1, 1]  // White
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

    mutating func updateColors(_ color: simd_float3) {
        colors = [color, color * 0.4, color * 0.5, color * 0.9]
        colorBuffer.contents().copyMemory(from: colors, byteCount: MemoryLayout<simd_float3>.stride * colors.count)
    }
}
