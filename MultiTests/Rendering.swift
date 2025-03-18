//
//  Rendering.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 17/03/2025.
//

import MetalKit

// Rendering
extension Model {
    func render(encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        for submesh in mesh.submeshes {
            encoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset
            )
        }
    }
}
