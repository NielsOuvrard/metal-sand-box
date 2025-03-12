//
//  VertexDescriptor.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 10/03/2025.
//

import MetalKit

extension MTLVertexDescriptor {
    static var defaultLayout: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        // only one attribute:
        // the position of each vertex
        let stride = MemoryLayout<Vertex>.stride
        vertexDescriptor.layouts[0].stride = stride

        // color part
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.layouts[1].stride = MemoryLayout<simd_float3>.stride

        return vertexDescriptor
    }
}
