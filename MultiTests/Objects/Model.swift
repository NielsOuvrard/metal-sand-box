//
//  Model.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 17/03/2025.
//


import MetalKit

class Model: Transformable {
    var meshes: [Mesh] = []
    var name: String = "Untitled"
    var transform = Transform()
    var tiling: UInt32 = 1
    
    init() {}
    
    init(name: String) {
        guard let assetURL = Bundle.main.url(
            forResource: name,
            withExtension: nil) else {
            fatalError("Model: \(name) not found")
        }
        
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(
            url: assetURL,
            vertexDescriptor: .defaultLayout,
            bufferAllocator: allocator)
        asset.loadTextures()
        let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(asset: asset, device: Renderer.device)
        meshes = zip(mdlMeshes, mtkMeshes).map {
            Mesh(mdlMesh: $0.0, mtkMesh: $0.1)
        }
        self.name = name
    }
}

extension Model {
    func setTexture(name: String, type: TextureIndices) {
        if let texture = TextureController.loadTexture(name: name) {
            switch type {
            case BaseColor:
                meshes[0].submeshes[0].textures.baseColor = texture
            default: break
            }
        }
    }
}

