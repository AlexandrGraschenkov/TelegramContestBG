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
    }
    
    var color: UIColor {
        didSet {
            color.getRed(&colorChannels.0, green: &colorChannels.1, blue: &colorChannels.2, alpha: &colorChannels.3)
        }
    }
    var pos: CGPoint
    
    fileprivate var colorChannels: (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
    
    var shader: MetaballShader {
        return MetaballShader(xy: vector_float2(Float(pos.x), Float(pos.y)),
                              color: vector_float3(
                                Float(colorChannels.0),
                                Float(colorChannels.1),
                                Float(colorChannels.2)))
    }
}

struct MetaballShader {
    var xy: vector_float2
    var color: vector_float3
}
