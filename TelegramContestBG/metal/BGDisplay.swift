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
    var reso: vector_float2
}

private extension MTLDevice {
    func makeBuffer<T>(arr: inout [T], options: MTLResourceOptions = []) -> MTLBuffer? {
        return makeBuffer(bytes: arr, length: MemoryLayout<T>.stride * arr.count, options: options)
    }
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
        
        let size = vector_float2(Float(view.drawableSize.width), Float(view.drawableSize.height))
        globalParams = GlobalParameters(metaballCount: 0, reso: size)
    }
    
    func prepareDisplay() {
    }
    
    func update(drawableSize: CGSize) {
        globalParams.reso = vector_float2(Float(drawableSize.width), Float(drawableSize.height))
    }
    
    func update(metaballs: [Metaball]) {
        if globalParams.metaballCount != UInt32(metaballs.count) {
            globalParams.metaballCount = UInt32(metaballs.count)
//            metaballsArr = PageAlignedContiguousArray<MetaballShader>(repeating: MetaballShader(xy: vector_float2(), color: vector_float3()), count: metaballs.count)
//            metaballsBuffer = device.makeBufferWithPageAlignedArray(metaballsArr)
        }
        
        var metaShaderVals = metaballs.map{$0.shader}
        metaballsBuffer = device.makeBuffer(arr: &metaShaderVals)
        print(metaballsBuffer)
//        updateBuffer(time, metaballsBuffer)
        
//        for (i,m) in metaballs.enumerated() {
//            metaballsArr[i] = m.shader
//        }
    }
    
    func display(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentBuffer(metaballsBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBytes(&globalParams, length: MemoryLayout<GlobalParameters>.stride, index: 1)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
    
    private func updateBuffer<T>(_ data:T, _ buffer: MTLBuffer) {
        let pointer = buffer.contents()
        let value = pointer.bindMemory(to: T.self, capacity: 1)
        value[0] = data
    }
}
