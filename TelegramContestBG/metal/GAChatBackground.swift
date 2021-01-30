//
//  ChatBackground.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 28.01.2021.
//

import UIKit

class GAChatBackground: BGRenderView {

    private(set) var progress: CGFloat = 0
    private(set) var animating: Bool = false
    private(set) var cancelLastAnim: (()->())?
    private var unsubscribe: (()->())?
    
    deinit {
        unsubscribe?()
    }
    
    func subscribeToSharedSettings() {
        unsubscribe?()
        unsubscribe = GAChatAnimModel.subscribeSharedChange {[weak self] (sett) in
            self?.timing = sett.backgroundTiming
            self?.colors = sett.backgroundColors
        }
    }
    
    var timing: GATimingModel = .zero {
        didSet { colorsOrPointsUpdates() }
    }
    var colors: [UIColor] = [
        UIColor(red:1.00, green:0.96, blue:0.79, alpha:1.00),
        UIColor(red:0.26, green:0.43, blue:0.34, alpha:1.00),
        UIColor(red:0.97, green:0.89, blue:0.55, alpha:1.00),
        UIColor(red:0.53, green:0.64, blue:0.52, alpha:1.00)
    ] {
        didSet { colorsOrPointsUpdates() }
    }
    let origPoints: [CGPoint] = [
        CGPoint(x: 0.36, y: 0.25),
        CGPoint(x: 0.19, y: 0.91),
        CGPoint(x: 0.64, y: 0.75),
        CGPoint(x: 0.81, y: 0.09)
    ]
    
    override func setup() {
        colorsOrPointsUpdates()
        timing.durationF = 60
    }

    func colorsOrPointsUpdates() {
        var metaballs: [Metaball] = []
        for i in 0..<origPoints.count {
            let offset: CGFloat = CGFloat(i) / CGFloat(origPoints.count)
            var percOffset = offset + progress
            while percOffset > 1 {
                percOffset -= 1
            }
            
            let pos = interpolate(points: origPoints, val: Float(percOffset))
            let m = Metaball(color: colors[i], pos: pos)
            metaballs.append(m)
        }
        update(metaballs: metaballs)
//        print("Prog: ", progress)
    }
    
    func runNextAnim() {
        if animating { return }
        animating = true
        
        var fromProgress = round(progress * 4) / 4
        while fromProgress >= 1 {
            fromProgress -= 1
        }
        var toProgress = round(progress * 4 + 1) / 4
        while toProgress > 1 {
            toProgress = toProgress - 1
        }
        let cancel = GADisplayLinkAnimator.animate(duration: Double(timing.durationSec)) {[weak self] (percent) in
            guard let `self` = self else { return }
            
            let done = percent == 1
            var percent = self.timing.process(progress: percent)
            percent = percent * (toProgress - fromProgress) + fromProgress
            self.progress = percent
            self.colorsOrPointsUpdates()
            
            if done {
                self.animating = false
            }
        }
        self.cancelLastAnim = {[weak self] in
            self?.animating = false
            cancel()
        }
    }
}

fileprivate extension GAChatBackground {
    
    func interpolate(points: [CGPoint], val: Float) -> CGPoint {
        var val = val
        if val >= 1 {
            val -= 1
        }
        let idx1 = Int(Float(points.count) * val) % points.count
        let idx2 = (idx1 + 1) % points.count
        
        var percent = CGFloat(val) - CGFloat(idx1) / CGFloat(points.count)
        percent /= 1 / CGFloat(points.count) // normalize
        
        let p1 = points[idx1]
        let p2 = points[idx2]
        let res = CGPoint(x: percent * (p2.x - p1.x) + p1.x,
                          y: percent * (p2.y - p1.y) + p1.y)
        return res
    }
}


