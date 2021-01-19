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
