//
//  metal_extensions.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 19.01.2021.
//

import UIKit
import MetalKit

extension MTLDevice {
    func loadTexture(imgPath: String) -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: self)
        let data = try! Data(contentsOf: URL(fileURLWithPath: imgPath))
        let tex = try! textureLoader.newTexture(data: data, options: nil)
        return tex
    }
}
//
//extension UIImage {
//    func texture(device: MTLDevice) -> MTLTexture? {
//        let textureLoader = MTKTextureLoader(device: device)
//        
//        do{
//            let texture = try textureLoader.newTexture(cgImage: cgImage!, options: nil)
//            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: texture.pixelFormat, width: size.width, height: size.height, mipmapped: false)
//            textureDescriptor.usage = [.shaderRead, .shaderWrite]
//            return texture
//        } catch {
//            fatalError("Couldn't convert CGImage to MTLtexture")
//        }
//                
//    }
//}
