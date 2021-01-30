//
//  TimeClipSlider.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 17.01.2021.
//

import UIKit

//class TimeClipSeparator: UIView {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setup()
//    }
//
//    var line: CAShapeLayer!
//    var circle1: CAShapeLayer!
//    var circle2: CAShapeLayer!
//    func setup() {
//        line = CAShapeLayer()
//        line.line
//    }
//}

class GATimeClipSlider: UISlider {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        setThumbImage(UIImage(named: "ChatAnimSettings/clip_thumb_slider"), for: .normal)
        let clear = UIImage(named: "ChatAnimSettings/clear")
        setMinimumTrackImage(clear, for: .normal)
        setMaximumTrackImage(clear, for: .normal)
//        isExclusiveTouch = true
//        isContinuous = false
        
        let lineImg = UIImage(named: "ChatAnimSettings/clip_thumb_line")?.resizableImage(withCapInsets: UIEdgeInsets(top: 25, left: 7, bottom: 25, right: 7), resizingMode: .tile)
        line = UIImageView(image: lineImg)
        line.frame = CGRect(x: 0, y: 0, width: lineImg!.size.width, height: 100)
        insertSubview(line, at: 0)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var res = super.trackRect(forBounds: bounds)
        res.origin.x = 2.0
        res.size.width = bounds.size.width - 4
        return res
    }
    
    var thumbRect: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
    }
    
    var line: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let x = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value).midX
        var fr = line.frame
        fr.origin.x = x - fr.width / 2.0
        fr.origin.y = -7.5
        fr.size.height = 15 + bounds.height
        line.frame = fr
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var thumb = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
        thumb = thumb.inset(top: 4, left: 4, bottom: 4, right: 4)
        if thumb.contains(point) {
            return self
        }
//        let res = super.hitTest(point, with: event)
//        print("Res", value, thumb, res)
        return nil
    }
}
