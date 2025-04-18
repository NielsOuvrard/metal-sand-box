//
//  Primitive.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 24/03/2025.
//


import MetalKit
// swiftlint:disable force_try

enum Primitive {
    case plane, sphere, box
}

extension Model {
    // convenience = secondary initializer
    convenience init(name: String, primitiveType: Primitive) {
        let mdlMesh = Self.createMesh(primitiveType: primitiveType)
        mdlMesh.vertexDescriptor = MDLVertexDescriptor.defaultLayout
        let mtkMesh = try! MTKMesh(mesh: mdlMesh, device: Renderer.device)
        let mesh = Mesh(mdlMesh: mdlMesh, mtkMesh: mtkMesh)
        self.init()
        self.meshes = [mesh]
        self.name = name
    }
    
    static func createMesh(primitiveType: Primitive) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        switch primitiveType {
        case .plane:
            return MDLMesh(
                planeWithExtent: [1, 1, 1],
                segments: [4, 4],
                geometryType: .triangles,
                allocator: allocator)
        case .sphere:
            return MDLMesh(
                sphereWithExtent: [1, 1, 1],
                segments: [30, 30],
                inwardNormals: false,
                geometryType: .triangles,
                allocator: allocator)
        case .box:
            return MDLMesh(
                boxWithExtent: [1, 1, 1],
                segments: [1, 1, 1],
                inwardNormals: false,
                geometryType: .triangles,
                allocator: allocator)
        }
    }
}
