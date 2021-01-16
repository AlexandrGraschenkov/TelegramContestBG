//
//  BGDisplay.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 16.01.2021.
//

import UIKit
import MetalKit


struct GlobalParameters {
    var metaballCount: UInt32
}

class BGDisplay: NSObject {
    private let view: BGRenderView
    private let device: MTLDevice
    
    var pipelineDescriptor = MTLRenderPipelineDescriptor()
    var pipelineState : MTLRenderPipelineState! = nil
    var globalParams: GlobalParameters
    var metaballsBuffer: MTLBuffer!
    var metaballsArr: PageAlignedContiguousArray<MetaballShader>!
    
    
    init(view: BGRenderView, device: MTLDevice) {
        self.view = view
        self.device = device
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        // Run with 4x MSAA:
        pipelineDescriptor.sampleCount = 4
        
        let library = device.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "metaball_vertex")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "metaball_fragment")
        
        pipelineState = (try? device.makeRenderPipelineState(descriptor: pipelineDescriptor))!
        
        globalParams = GlobalParameters(metaballCount: 0)
    }
    
    func prepareDisplay() {
//        super.prepareDisplay()
//        let scale = Float(UIScreen.main.scale)
//        view.globalParams.lineWidth = view.isSelectionChart ? 1.5*scale : 2.0*scale
    }
    
    func update(metaballs: [Metaball]) {
        if globalParams.metaballCount != UInt32(metaballs.count) {
            globalParams.metaballCount = UInt32(metaballs.count)
            metaballsArr = PageAlignedContiguousArray<MetaballShader>(repeating: MetaballShader(xy: vector_float2(), color: vector_float3()), count: metaballs.count)
        }
        
        for (i,m) in metaballs.enumerated() {
            metaballsArr[i] = m.shader
        }
    }
    
    func display(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setFragmentBuffer(metaballsBuffer, offset: 0, index: 0)
//        renderEncoder.setFragmentBytes(&view.globalParams, length: MemoryLayout<GlobalParameters>.stride, index: 1)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
}
