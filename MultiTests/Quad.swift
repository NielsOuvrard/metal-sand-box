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

struct Quad {
    var vertices: [Vertex] = [
        Vertex(x: -1, y:  1, z: 0), // triangle 1
        Vertex(x:  1, y: -1, z: 0),
        Vertex(x: -1, y: -1, z: 0),
        Vertex(x: -1, y:  1, z: 0), // triangle 2
        Vertex(x:  1, y:  1, z: 0),
        Vertex(x:  1, y: -1, z: 0)
    ]
    let vertexBuffer: MTLBuffer
    
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
    }
}
