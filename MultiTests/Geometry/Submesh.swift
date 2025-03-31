//
//  Submesh.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 24/03/2025.
//


import MetalKit

struct Submesh {
    let indexCount: Int
    let indexType: MTLIndexType
    let indexBuffer: MTLBuffer
    let indexBufferOffset: Int
    
    struct Textures {
        var baseColor: MTLTexture?
    }
    var textures: Textures
}

extension Submesh {
    init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
        indexCount = mtkSubmesh.indexCount
        indexType = mtkSubmesh.indexType
        indexBuffer = mtkSubmesh.indexBuffer.buffer
        indexBufferOffset = mtkSubmesh.indexBuffer.offset
        textures = Textures(material: mdlSubmesh.material)
    }
}

private extension Submesh.Textures {
    init(material: MDLMaterial?) {
        baseColor = material?.texture(type: .baseColor)
    }
}

private extension MDLMaterialProperty {
    var textureName: String {
        stringValue ?? UUID().uuidString
    }
}

private extension MDLMaterial {
    func texture(type semantic: MDLMaterialSemantic) ->
    MTLTexture? {
        if let property = property(with: semantic),
           property.type == .texture,
           let mdlTexture = property.textureSamplerValue?.texture {
            return TextureController.loadTexture(
                texture: mdlTexture,
                name: property.textureName)
        }
        return nil
    }
}
