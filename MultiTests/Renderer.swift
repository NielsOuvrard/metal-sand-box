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

    var pipelineState: MTLRenderPipelineState!
    let depthStencilState: MTLDepthStencilState?

    var timer: Float = 0
    var uniforms = Uniforms()
    var params = Params()
    
    // controls
    var cameraPosition: CGPoint = .zero
    var cameraAngle: CGPoint = .zero
    var leftJoystick: CGPoint = .zero
    var rightJoystick: CGPoint = .zero
    
    // the models to render
    lazy var box: Model = { // lazy = initialized only when it's first used
        var box = Model(name: "box", primitiveType: .box) // Quad(device: Self.device, scale: 0.8)
        //box.updateColors([1, 0, 0])
        box.position.x = 2.8
        box.position.y = 1
        box.position.z = 0
        box.setTexture(name: "steel", type: BaseColor)
        return box
    }()
    
    lazy var rocket: Model = {
        Model(name: "rocket.usdz")
    }()
    
    lazy var house: Model = {
        Model(name: "lowpoly-house.usdz")
    }()
    
    lazy var ground: Model = {
        let ground = Model(name: "ground", primitiveType: .plane)
        ground.setTexture(name: "grass", type: BaseColor)
        ground.tiling = 16
        return ground
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
        // metalView.colorPixelFormat = .bgra8Unorm_srgb
        
        // create the shader function library
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        // create the pipeline state object
        
        // Creating pipeline states is relatively time-consuming
        // which is why you do it up-front
        // but switching pipeline states during frames is fast and efficient
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        depthStencilState = Renderer.buildDepthStencilState()
        super.init()
        
        //metalView.clearColor = MTLClearColor(red: 0.3, green: 0.6, blue: 1, alpha: 1.0)
        metalView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
    }
    
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }

    func updateLeftJoystickPosition(_ joystickPosition: CGPoint, view: MTKView) {
        self.leftJoystick = joystickPosition
    }
    
    func updateRightJoystickPosition(_ joystickPosition: CGPoint, view: MTKView) {
        self.rightJoystick = joystickPosition
    }

    func updateColor(_ color: simd_float4) {
        //box.updateColors(color.xyz)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        let aspect = Float(view.bounds.width) / Float(view.bounds.height)
        let projectionMatrix = float4x4(projectionFov: Float(70).degreesToRadians, near: 0.1, far: 100, aspect: aspect)
        uniforms.projectionMatrix = projectionMatrix
        
        params.width = UInt32(size.width)
        params.height = UInt32(size.height)
    }
    
    func updateProjecionMatrix(deltaTime: TimeInterval) {
        cameraPosition.x += leftJoystick.x * deltaTime
        cameraPosition.y += leftJoystick.y * deltaTime
        
        cameraAngle.x += rightJoystick.x * deltaTime
        cameraAngle.y += rightJoystick.y * deltaTime

        // left-handed coordinate system
        // We change the X and Z coordinates to move the camera
        let cameraTranslation = float4x4(translation: float3(Float(cameraPosition.x), 0, Float(cameraPosition.y))).inverse
        let cameraRotation = float4x4(rotation: float3(Float(cameraAngle.y), Float(cameraAngle.x), 0)).inverse
        

        // the camera is rotated around the origin
        // TODO: change the rotation to be around the camera position
        // projectionMatrix *= cameraTranslation

        uniforms.viewMatrix = cameraTranslation * cameraRotation
    }
    
    func draw(in view: MTKView) {
        guard
            let commandBuffer = Self.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else {
            return
        }

        //renderEncoder.setTriangleFillMode(.lines)
        timer += 0.005
        uniforms.viewMatrix = float4x4(translation: [0, 1.4, -4.0]).inverse
        uniforms.viewMatrix *= float4x4(rotation: float3(0, Float(sin(timer)), 0)).inverse
        
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        
        
        // When possible, use indexed rendering. With indexed rendering, you pass less data to the GPU
        // memory bandwidth is a major bottleneck
        
        // You can pass any data in an MTLBuffer to the GPU using setVertexBuffer(_:offset:index:)
        // If the data is less than 4KB -> pass a structure using setVertexBytes(_:length:index:)
        renderEncoder.setVertexBytes(&timer, length: MemoryLayout<Float>.stride, index: 11)
        
        // Box
        renderEncoder.setCullMode(.front)
        renderEncoder.setFrontFacing(.counterClockwise)
        box.rotation.x = sin(timer)
        box.rotation.z = cos(timer)
        box.render(encoder: renderEncoder, uniforms: uniforms, params: params)
        
        // House
        house.render(encoder: renderEncoder, uniforms: uniforms, params: params)

        // Rocket
        rocket.position.x = -3
        rocket.position.y = 0.5
        rocket.rotation.z = -0.6
        rocket.rotation.x = cos(timer)
        rocket.scale = 0.1
        rocket.render(encoder: renderEncoder, uniforms: uniforms, params: params)
        
        // Ground
        renderEncoder.setCullMode(.back)
        // renderEncoder.setCullMode(.front)
        // renderEncoder.setFrontFacing(.clockwise)
        ground.scale = 40
        ground.rotation.z = Float(90).degreesToRadians
        ground.render(encoder: renderEncoder, uniforms: uniforms, params: params)
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
