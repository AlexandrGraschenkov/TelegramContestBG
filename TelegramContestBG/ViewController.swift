//
//  ViewController.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 16.01.2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var renderView: BGRenderView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var timeControl: TimingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: 1, height: timeControl.frame.maxY + 20)
        renderView.update(metaballs: generateMetaballs(percent: 0))
        timeControl.model = TimingModel(durationF: 60, startOffsetF: 0, endOffsetF: 0, startEase: 0, endEase: 0)
    }


    func generateMetaballs(percent: CGFloat) -> [Metaball] {
        let points: [CGPoint] = [
            CGPoint(x: 0.2, y: 0.2),
            CGPoint(x: 0.8, y: 0.2),
            CGPoint(x: 0.8, y: 0.8),
            CGPoint(x: 0.2, y: 0.8)
        ]
        
        var colors: [UIColor] = [.red, .green, .blue, .yellow]
        var metaballs: [Metaball] = []
        for (i, c) in colors.enumerated() {
            let offset: CGFloat = CGFloat(i) / CGFloat(points.count)
            var percOffset = offset + percent
            while percOffset > 1 {
                percOffset -= 1
            }
            
            let m = Metaball(color: c, pos: interpolate(points: points, val: Float(percOffset)))
            metaballs.append(m)
        }
        
        return metaballs
//        return [
//            Metaball(color: UIColor.red, pos: CGPoint(x: 0.2, y: 0.2)),
//            Metaball(color: UIColor.green, pos: CGPoint(x: 0.8, y: 0.2)),
//            Metaball(color: UIColor.blue, pos: CGPoint(x: 0.8, y: 0.8)),
//            Metaball(color: UIColor.yellow, pos: CGPoint(x: 0.2, y: 0.8))
//        ]
    }
    
    func interpolate(points: [CGPoint], val: Float) -> CGPoint {
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
    
    @IBAction func runAnim() {
        _ = DisplayLinkAnimator.animate(duration: 5.0) { (percent) in
            var percent = percent
            if percent == 1 {
                percent = 0
            }
            self.renderView.update(metaballs: self.generateMetaballs(percent: percent))
        }
    }
}

