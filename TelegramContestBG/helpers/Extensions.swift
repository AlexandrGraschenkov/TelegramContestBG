//
//  Extensions.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 16.01.2021.
//

import UIKit

/**
 * Adds two CGPoint values and returns the result as a new CGPoint.
 */
public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

/**
 * Increments a CGPoint with the value of another.
 */
public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

/**
 * Subtracts two CGPoint values and returns the result as a new CGPoint.
 */
public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

/**
 * Decrements a CGPoint with the value of another.
 */
public func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}


/**
 * Multiplies two CGPoint values and returns the result as a new CGPoint.
 */
public func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

/**
 * Multiplies a CGPoint with another.
 */
public func *= (left: inout CGPoint, right: CGPoint) {
    left = left * right
}


/**
 * Multiplies the x and y fields of a CGPoint with the same scalar value and
 * returns the result as a new CGPoint.
 */
public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

/**
 * Multiplies the x and y fields of a CGPoint with the same scalar value.
 */
public func *= (point: inout CGPoint, scalar: CGFloat) {
    point = point * scalar
}

extension CGRect {
    var tl: CGPoint {
        return origin
    }
    
    var tr: CGPoint {
        return CGPoint(x: origin.x + width, y: origin.y)
    }
    
    var bl: CGPoint {
        return CGPoint(x: origin.x, y: origin.y + height)
    }
    
    var br: CGPoint {
        return CGPoint(x: origin.x + width, y: origin.y + height)
    }
    
    //
    //    var x: CGFloat {
    //        set {
    //            origin.x = newValue
    //        }
    //        get {
    //            return origin.x
    //        }
    //    }
    //
    //    var y: CGFloat {
    //        set {
    //            origin.y = newValue
    //        }
    //        get {
    //            return origin.y
    //        }
    //    }
    
    func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> CGRect {
        return inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }
    
    func roundRect(scale: CGFloat = 1) -> CGRect {
        var p1 = origin
        var p2 = br
        p1.x = round(p1.x * scale) / scale
        p1.y = round(p1.y * scale) / scale
        p2.x = round(p2.x * scale) / scale
        p2.y = round(p2.y * scale) / scale
        return CGRect(x: p1.x, y: p1.y, width: p2.x-p1.x, height: p2.y-p1.y)
    }
}

extension CGPoint {
    func offset(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
}

extension UIImage {
    func resizing(all: CGFloat) -> UIImage {
        return resizableImage(withCapInsets: UIEdgeInsets(top: all, left: all, bottom: all, right: all))
    }
    func resizing(w: CGFloat, h: CGFloat) -> UIImage {
        return resizableImage(withCapInsets: UIEdgeInsets(top: h, left: w, bottom: h, right: w))
    }
    func resizingCenter() -> UIImage {
        return resizableImage(withCapInsets: UIEdgeInsets(top: size.height / 2.0, left: size.width / 2.0, bottom: size.height / 2.0, right: size.width / 2.0))
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "").uppercased()
        
        if hex.count == 6 {
            let scanner = Scanner(string: hex)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                let r, g, b: CGFloat
                r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x000000ff) / 255
                
                self.init(red: r, green: g, blue: b, alpha: 1)
                return
            }
        }
        
        return nil
    }
    
    func hex() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let hexString = String.init(format: "%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        
        return hexString
    }
    
    func isLight(threshold: Float = 0.6) -> Bool {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let brightness = Float(((r * 299) + (g * 587) + (b * 114)) / 1000)
        return (brightness > threshold)
    }
}
