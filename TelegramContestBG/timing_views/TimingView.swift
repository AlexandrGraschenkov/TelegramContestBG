//
//  AnimTimeView.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 16.01.2021.
//

import UIKit

class TimingControl: UIControl {
    
    var controlInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    var topSlider: UISlider!
    var botSlider: UISlider!
    var timingLayer: CAShapeLayer!
    var timeOffsetBegin: CGFloat = 0
    var timeOffsetEnd: CGFloat = 0
    var model: TimingModel = TimingModel(duration: 1, startEase: 0, endEase: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func updateTiming() {
        let bezier = UIBezierPath()
        let rect = bounds.inset(by: controlInset)
        bezier.move(to: rect.tl)
        bezier.addLine(to: rect.tr)
        
        let tr = rect.tr.offset(x: -timeOffsetEnd*rect.width)
        let bl = rect.bl.offset(x: timeOffsetBegin*rect.width)
        bezier.move(to: bl)
        let w = tr.x - bl.x
        bezier.addCurve(to: tr,
                        controlPoint1: bl.offset(x: w*model.startEase),
                        controlPoint2: tr.offset(x: -w*model.endEase))
        
        bezier.move(to: rect.bl)
        bezier.addLine(to: rect.br)
        
        timingLayer.path = bezier.cgPath
    }
    
    func setup() {
        if timingLayer != nil {
            return
        }
        
        timingLayer = CAShapeLayer()
        timingLayer.frame = bounds
        timingLayer.lineWidth = 6
        timingLayer.strokeColor = UIColor(red:0.89, green:0.89, blue:0.90, alpha:1.00).cgColor
        timingLayer.lineJoin = .round
        timingLayer.lineCap = .round
        layer.addSublayer(timingLayer)
        
        // Sliders
        let rect = bounds.inset(by: controlInset)
        let sliderHeight: CGFloat = 10
        topSlider = UISlider(frame: CGRect(x: rect.minX, y: rect.minY - sliderHeight/2, width: rect.width, height: sliderHeight))
        topSlider.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        topSlider.addTarget(self, action: #selector(sliderChanges(_:)), for: .valueChanged)
        addSubview(topSlider)
        
        botSlider = UISlider(frame: CGRect(x: rect.minX, y: rect.maxY - sliderHeight/2, width: rect.width, height: sliderHeight))
        botSlider.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        botSlider.addTarget(self, action: #selector(sliderChanges(_:)), for: .valueChanged)
        addSubview(botSlider)
    }
    
    @objc func sliderChanges(_ slider: UISlider) {
        if slider == topSlider {
            timeOffsetEnd = CGFloat(1 - slider.value)
        } else if slider == botSlider {
            timeOffsetBegin = CGFloat(slider.value)
        }
        updateTiming()
    }
}
