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
    
    var display: BGDisplay!
    var globalParams: GlobalParameters!
    let mutex = Mutex()

    override init(frame frameRect: CGRect, device: MTLDevice?)
    {
        let d = device ?? MTLCreateSystemDefaultDevice()!
        super.init(frame: frameRect, device: d)
        configureWithDevice(d)
    }
    
    required init(coder: NSCoder)
    {
        super.init(coder: coder)
        configureWithDevice(MTLCreateSystemDefaultDevice()!)
    }
    
    private func configureWithDevice(_ device : MTLDevice) {
//        let viewport = (Float(drawableSize.width) / 2.0,
//                        Float(drawableSize.height) / 2.0)
        
        clearColor = MTLClearColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        framebufferOnly = true
        colorPixelFormat = .bgra8Unorm
        
        // Run with 4rx MSAA:
        sampleCount = 4
        
        preferredFramesPerSecond = 60
        isPaused = true
        enableSetNeedsDisplay = true
        
        self.device = device
        display = BGDisplay(view: self, device: device)
    }
    
    override var device: MTLDevice! {
        didSet {
            super.device = device
            commandQueue = (self.device?.makeCommandQueue())!
            
        }
    }
    
    override func draw(_ rect: CGRect) {
//        if chartDataCount == 0 { return }
//        globalParams.halfViewport = (Float(drawableSize.width) / 2.0,
//                                     Float(drawableSize.height) / 2.0)
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
    }
}
