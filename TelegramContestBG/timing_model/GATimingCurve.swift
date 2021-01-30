//
//  Timing.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 20.01.2021.
//

import UIKit

class GATimingCurve {
    
    public static let `default`: GATimingCurve = GATimingCurve(functionName: .default)
    public static let linear: GATimingCurve = GATimingCurve(closure: {$0})
    public static let easeIn: GATimingCurve = GATimingCurve(functionName: .easeIn)
    public static let easeOut: GATimingCurve = GATimingCurve(functionName: .easeOut)
    public static let easeInOut: GATimingCurve = GATimingCurve(functionName: .easeInEaseOut)
    
    public convenience init(functionName: CAMediaTimingFunctionName) {
        self.init(function: CAMediaTimingFunction(name: functionName))
    }
    
    public convenience init(function: CAMediaTimingFunction) {
        var p1: [Float] = [0.0,0.0]
        var p2: [Float] = [0.0,0.0]
        
        function.getControlPoint(at: 1, values: &p1)
        function.getControlPoint(at: 2, values: &p2)
        
        self.init(cp1: CGPoint(x: CGFloat(p1[0]), y: CGFloat(p1[1])),
                  cp2: CGPoint(x: CGFloat(p2[0]), y: CGFloat(p2[1])))
    }
    
    public init(cp1: CGPoint, cp2: CGPoint) {
        p1 = cp1
        p2 = cp2
        updateCoefficients()
    }
    
    public init(closure: @escaping (CGFloat)->(CGFloat)) {
        customClosure = closure
    }
    
    public func getValue(x: CGFloat, duration: CGFloat = 1.0) -> CGFloat {
        if let closure = customClosure {
            return closure(x)
        }
        
        let eps = 1.0 / (200.0 * duration)
        let t = solve(x: x, epsilon: eps)
        return getSampleCurveY(t: t)
    }
    
    // MARK: - Private
    
    fileprivate(set) var p1: CGPoint = .zero
    fileprivate(set) var p2: CGPoint = CGPoint(x: 1, y: 1)
    fileprivate var cx: CGFloat = 0
    fileprivate var bx: CGFloat = 0
    fileprivate var ax: CGFloat = 0
    fileprivate var cy: CGFloat = 0
    fileprivate var by: CGFloat = 0
    fileprivate var ay: CGFloat = 0
    fileprivate var customClosure: ((CGFloat)->(CGFloat))? = nil
    
    fileprivate func updateCoefficients() {
        cx = 3.0 * p1.x
        bx = 3.0 * (p2.x - p1.x) - cx
        ax = 1.0 - cx - bx
        
        cy = 3.0 * p1.y
        by = 3.0 * (p2.y - p1.y) - cy
        ay = 1.0 - cy - by
    }
    
    fileprivate func getSampleCurveX(t: CGFloat) -> CGFloat {
        return ((ax * t + bx) * t + cx) * t
    }
    
    fileprivate func getSampleCurveY(t: CGFloat) -> CGFloat {
        return ((ay * t + by) * t + cy) * t
    }
    
    fileprivate func getSampleCurveDerivativeX(t: CGFloat) -> CGFloat {
        return (3.0 * ax * t + 2.0 * bx) * t + cx
    }
    
    
    fileprivate func solve(x: CGFloat, epsilon: CGFloat) -> CGFloat {
        var t0: CGFloat = 0
        var t1: CGFloat = 0
        var t2: CGFloat = x
        var x2: CGFloat = 0
        var d2: CGFloat = 0
        
        // First try a few iterations of Newton's method -- normally very fast.
        for _ in 0..<8 {
            x2 = getSampleCurveX(t: t2) - x
            if (abs(x2) < epsilon) {
                return t2
            }
            
            d2 = getSampleCurveDerivativeX(t: t2)
            if (abs(d2) < 1e-6) {
                break
            }
            t2 = t2 - x2 / d2
        }
        
        // Fall back to the bisection method for reliability.
        t0 = 0.0
        t1 = 1.0
        t2 = x
        
        if (t2 < t0) {
            return t0
        }
        if (t2 > t1) {
            return t1
        }
        
        while (t0 < t1) {
            x2 = getSampleCurveX(t: t2)
            if (abs(x2 - x) < epsilon) {
                return t2
            }
            if (x > x2) {
                t0 = t2
            } else {
                t1 = t2
            }
            t2 = (t1 + t0) * 0.5
        }
        
        // Failure.
        return t2
    }
}
