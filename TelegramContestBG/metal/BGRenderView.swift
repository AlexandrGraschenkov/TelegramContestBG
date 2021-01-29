//
//  BackgroundRender.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 16.01.2021.
//

import UIKit
import MetalKit


class BGRenderView: MTKView {
    
    private var commandQueue: MTLCommandQueue! = nil
    private var display: BGDisplay!
    private let mutex = Mutex()

    override init(frame frameRect: CGRect, device: MTLDevice?)
    {
        let d = device ?? MTLCreateSystemDefaultDevice()!
        super.init(frame: frameRect, device: d)
        configureWithDevice(d)
        setup()
    }
    
    required init(coder: NSCoder)
    {
        super.init(coder: coder)
        configureWithDevice(MTLCreateSystemDefaultDevice()!)
        setup()
    }
    
    private func configureWithDevice(_ device : MTLDevice) {
        clearColor = MTLClearColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        framebufferOnly = true
        colorPixelFormat = .bgra8Unorm
        depthStencilPixelFormat = .invalid
        
        // Run with 4rx MSAA:
        sampleCount = 4
        
        preferredFramesPerSecond = 60
        isPaused = true
        enableSetNeedsDisplay = true
        
        self.device = device
        display = BGDisplay(view: self, device: device)
        delegate = self
    }
    
    override var device: MTLDevice! {
        didSet {
            super.device = device
            commandQueue = (self.device?.makeCommandQueue())!
        }
    }
    
    override func draw(_ rect: CGRect) {
        drawAll()
    }
    
    open func setup() {
        
    }
    
    func drawAll() {
        display.prepareDisplay()
        
        mutex.lock()
        
        guard let commandBuffer = commandQueue!.makeCommandBuffer(),
            let renderPassDescriptor = self.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                mutex.unlock()
            return
        }
        commandBuffer.addCompletedHandler { (_) in
            self.mutex.unlock()
        }
        
        display.display(renderEncoder: renderEncoder)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(self.currentDrawable!)
        commandBuffer.commit()
    }
    
    func update(metaballs: [Metaball]) {
        mutex.lock()
        defer { mutex.unlock() }
        
        display.update(metaballs: metaballs)
        setNeedsDisplay()
    }
    
    func update(gradient: Float? = nil, scale: Float? = nil) {
        mutex.lock()
        defer { mutex.unlock() }
        
        if let g = gradient {
            display.globalParams.gradient = g
        }
        if let s = scale {
            display.globalParams.scale = s
        }
        setNeedsDisplay()
    }
}

extension BGRenderView: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        mutex.lock()
        defer { mutex.unlock() }
        
        (view as? BGRenderView)?.display.update(drawableSize: size)
    }
    
    func draw(in view: MTKView) {
        (view as? BGRenderView)?.drawAll()
    }
    
}
