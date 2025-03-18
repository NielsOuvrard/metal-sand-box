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
    
    private var lastFrameTime: CFTimeInterval = 0
    private var frameCount: Int = 0
    
    var mesh: MTKMesh!
    var pointPipelineState: MTLRenderPipelineState!
    var trianglePipelineState: MTLRenderPipelineState!
    var meshPipelineState: MTLRenderPipelineState!
    var timer: Float = 0
    var total_points: UInt32 = 50
    
    // controls
    var cameraPosition: CGPoint = .zero
    var cameraAngle: CGPoint = .zero
    var leftJoystick: CGPoint = .zero
    var rightJoystick: CGPoint = .zero
    
    var modifier: CubeModifier = CubeModifier()
    var trainUniforms = Uniforms()
    var quadUniforms = Uniforms()
    
    // lazy = initialized only when it's first used
    lazy var quad: Quad = {
        var quad = Quad(device: Self.device, scale: 0.8)
        quad.updateColors([1, 0, 0])
        return quad
    }()
    
    lazy var model: Model = {
        Model(device: Renderer.device, name: "train.usdz")
    }()
    
    
    init(metalView: MTKView) {
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

    func updateTotalPoints(_ totalPoints: UInt32) {
        self.total_points = totalPoints
    }

    func updateLeftJoystickPosition(_ joystickPosition: CGPoint, view: MTKView) {
        self.leftJoystick = joystickPosition
    }
    
    func updateRightJoystickPosition(_ joystickPosition: CGPoint, view: MTKView) {
        self.rightJoystick = joystickPosition
    }

    func updateModifier(_ modifier: CubeModifier) {
        self.modifier = modifier
    }

    func updateColor(_ color: simd_float4) {
        quad.updateColors(color.xyz)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        let aspect = Float(view.bounds.width) / Float(view.bounds.height)
        let projectionMatrix = float4x4(projectionFov: Float(45).degreesToRadians, near: 0.1, far: 100, aspect: aspect)

        trainUniforms.projectionMatrix = projectionMatrix
        quadUniforms.projectionMatrix = projectionMatrix
    }
    
    func updateProjecionMatrix(view: MTKView, deltaTime: TimeInterval) {
        cameraPosition.x += leftJoystick.x * deltaTime
        cameraPosition.y += leftJoystick.y * deltaTime
        
        cameraAngle.x += rightJoystick.x * deltaTime
        cameraAngle.y += rightJoystick.y * deltaTime

        let aspect = Float(view.bounds.width) / Float(view.bounds.height)
        var projectionMatrix = float4x4(projectionFov: Float(45).degreesToRadians, near: 0.1, far: 100, aspect: aspect)

        // left-handed coordinate system
        // We change the X and Z coordinates to move the camera
        let cameraTranslation = float4x4(translation: float3(Float(cameraPosition.x), 0, Float(cameraPosition.y))).inverse
        let cameraRotation = float4x4(rotation: float3(Float(-cameraAngle.y), Float(cameraAngle.x), 0)).inverse
        

        // the camera is rotated around the origin
        // TODO: change the rotation to be around the camera position
        projectionMatrix *= cameraTranslation * cameraRotation  // * scale

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

        let currentTime = CACurrentMediaTime()
        if lastFrameTime > 0 {
            let deltaTime = currentTime - lastFrameTime
            updateProjecionMatrix(view: view, deltaTime: deltaTime)
        }
        lastFrameTime = currentTime
        
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
        
        quad.rotation.x = sin(timer)
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
        if (modifier.rotateX) {
            model.rotation.x = sin(timer)
        } else {
            model.rotation.x = modifier.angleX.degreesToRadians
        }
        if (modifier.rotateY) {
            model.rotation.y = cos(timer)
        } else {
            model.rotation.y = modifier.angleY.degreesToRadians
        }
        if (modifier.rotateZ) {
            model.rotation.z = sin(timer)
        } else {
            model.rotation.z = modifier.angleZ.degreesToRadians
        }
        trainUniforms.modelMatrix = model.transform.modelMatrix
        renderEncoder.setVertexBytes(&trainUniforms, length: MemoryLayout<Uniforms>.stride, index: 14)
        
        model.render(encoder: renderEncoder)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
