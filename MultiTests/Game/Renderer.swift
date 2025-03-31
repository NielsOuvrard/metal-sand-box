//
//  Renderer.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 03/02/2025.
//

import MetalKit


class MetalViewController: UIViewController {
    var metalView: MTKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Metal view
        metalView = MTKView(frame: view.bounds)
        metalView.device = MTLCreateSystemDefaultDevice()
        view.addSubview(metalView)
        
        // Hide home indicator
        setupHomeIndicator()
    }
    
    private func setupHomeIndicator() {
        if #available(iOS 11.0, *) {
            // This makes the home indicator auto-hide after a few seconds
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }
    
    // Required for hiding home indicator
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // Optional: Control edge protection
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .bottom
    }
}

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!

    var pipelineState: MTLRenderPipelineState!
    let depthStencilState: MTLDepthStencilState?

    
    lazy var scene = GameScene()
    
    var lastTime: Double = CFAbsoluteTimeGetCurrent()
    var uniforms = Uniforms()
    var params = Params()
    
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
        
        metalView.clearColor = MTLClearColor(red: 0.3, green: 0.6, blue: 1, alpha: 1.0)
        //metalView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1.0)
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
}

extension Renderer: MTKViewDelegate {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        scene.update(size: size)
    }

    func draw(in view: MTKView) {
        guard
            let commandBuffer = Self.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else {
            return
        }
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(currentTime - lastTime)
        lastTime = currentTime
        scene.update(deltaTime: deltaTime)


        renderEncoder.setCullMode(.front)
        renderEncoder.setFrontFacing(.counterClockwise)
        
        var lights = scene.lighting.lights
        renderEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: LightBuffer.index)
        
        uniforms.viewMatrix = scene.camera.viewMatrix
        uniforms.projectionMatrix = scene.camera.projectionMatrix
        params.lightCount = UInt32(scene.lighting.lights.count)
        params.cameraPosition = scene.camera.position

        for model in scene.models {
            model.render(encoder: renderEncoder, uniforms: uniforms, params: params)
        }

        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
