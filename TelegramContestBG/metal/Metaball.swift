//
//  Metaball.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 16.01.2021.
//

import Foundation
import UIKit
import MetalKit


struct Metaball {
    init(color: UIColor, pos: CGPoint) {
        self.color = color
        self.pos = pos
        updateChannels()
    }
    
    var color: UIColor {
        didSet {
            updateChannels()
        }
    }
    var pos: CGPoint
    
    fileprivate var channels: (Float, Float, Float)!
    
    mutating func updateChannels() {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        channels = (Float(r), Float(g), Float(b))
    }
    
    var shader: MetaballShader {
        return MetaballShader(xy: vector_float2(Float(pos.x), Float(pos.y)),
                              color: vector_float3(
                                channels.0,
                                channels.1,
                                channels.2),
                              temp: vector_float3())
    }
}

struct MetaballShader {
    var xy: vector_float2
    var color: vector_float3
    var temp: vector_float3
}
