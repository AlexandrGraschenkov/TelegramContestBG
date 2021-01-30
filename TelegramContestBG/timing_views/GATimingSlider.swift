//
//  TimingSlider.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 17.01.2021.
//

import UIKit

class GATimingSlider: UISlider {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var percent: CGFloat {
        return CGFloat(value - minimumValue) / CGFloat(maximumValue - minimumValue)
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
}
