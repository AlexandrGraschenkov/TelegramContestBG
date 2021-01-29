//
//  AnimTimeView.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 16.01.2021.
//

import UIKit

class TimingControl: UIControl {
    
    var controlInset = UIEdgeInsets(top: 50, left: 30, bottom: 50, right: 30)
    var sliderInset = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: -15)
    var sliderClipInset = UIEdgeInsets(top: 0, left: -17, bottom: 0, right: -17)
    
    var topSlider: TimingSlider!
    var botSlider: TimingSlider!
    var topLabel: UILabel!
    var botLabel: UILabel!
    var clipBeginSlider: TimeClipSlider!
    var clipEndSlider: TimeClipSlider!
    var clipBeginLabel: UILabel!
    var clipEndLabel: UILabel!
    var timingLayer: CAShapeLayer!
    var minTimeDistF: CGFloat = 5
    var onChange: ((TimingModel)->())?
    private var lastSliderRect: CGRect = .zero
    private let thumbSize: CGSize = CGSize(width: 30, height: 30)
    private var innerChangeModel: Bool = false
    var model: TimingModel = TimingModel.zero {
        didSet {
            if innerChangeModel {
                onChange?(model)
            } else {
                updatedModel()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: private
    
    private func updatedModel() {
        clipBeginSlider.maximumValue = Float(model.durationF)
        clipBeginSlider.value = Float(model.startOffsetF)
        clipEndSlider.maximumValue = Float(model.durationF)
        clipEndSlider.value = Float(model.durationF - model.endOffsetF)
        topSlider.value = Float(1 - model.endEase)
        botSlider.value = Float(model.startEase)
        
        updateCurve()
        layoutSliders()
    }
    
    private func updateCurve() {
        let bezier = UIBezierPath()
        let rect = bounds.inset(by: controlInset)
        bezier.move(to: rect.tl)
        bezier.addLine(to: rect.tr)
        
        let rectWidth = rect.width// - thumbSize.width
        let tr = rect.tr.offset(x: -model.endOffsetPercent * rectWidth)
        let bl = rect.bl.offset(x: model.startOffsetPercent * rectWidth)
        bezier.move(to: bl)
        let w = tr.x - bl.x
        bezier.addCurve(to: tr,
                        controlPoint1: bl.offset(x: w*model.startEase),
                        controlPoint2: tr.offset(x: -w*model.endEase))
        
        bezier.move(to: rect.bl)
        bezier.addLine(to: rect.br)
        
        timingLayer.path = bezier.cgPath
    }
    
    private func setup() {
        if timingLayer != nil {
            return
        }
//        backgroundColor = UIColor.yellow
        
        timingLayer = CAShapeLayer()
        timingLayer.frame = bounds
        timingLayer.lineWidth = 6
        timingLayer.strokeColor = UIColor(red:0.89, green:0.89, blue:0.90, alpha:1.00).cgColor
        timingLayer.fillColor = UIColor.clear.cgColor
        timingLayer.lineJoin = .round
        timingLayer.lineCap = .round
        layer.addSublayer(timingLayer)
        updateCurve()
        
        // Sliders
        let sliderImg = UIImage(named: "slider_2")?.resizingCenter()
        let clearImg = UIImage(named: "clear")
        
        topSlider = TimingSlider(frame: .zero)
        topSlider.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        topSlider.setMinimumTrackImage(clearImg, for: .normal)
        topSlider.setMaximumTrackImage(sliderImg, for: .normal)
        topSlider.addTarget(self, action: #selector(sliderChanges(_:)), for: .valueChanged)
        addSubview(topSlider)
        
        topLabel = UILabel()
        setupEase(label: topLabel)
        addSubview(topLabel)
        
        botSlider = TimingSlider(frame: .zero)
        botSlider.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        botSlider.setMinimumTrackImage(sliderImg, for: .normal)
        botSlider.setMaximumTrackImage(clearImg, for: .normal)
        botSlider.addTarget(self, action: #selector(sliderChanges(_:)), for: .valueChanged)
        addSubview(botSlider)
        
        botLabel = UILabel()
        setupEase(label: botLabel)
        addSubview(botLabel)
        
        clipEndSlider = TimeClipSlider(frame: .zero)
        insertSubview(clipEndSlider, at: 1)
        clipEndSlider.addTarget(self, action: #selector(sliderChanges(_:)), for: .valueChanged)
        clipBeginSlider = TimeClipSlider(frame: .zero)
        insertSubview(clipBeginSlider, at: 1)
        clipBeginSlider.addTarget(self, action: #selector(sliderChanges(_:)), for: .valueChanged)
        
        clipBeginLabel = UILabel()
        setupClip(label: clipBeginLabel)
        addSubview(clipBeginLabel)
        
        clipEndLabel = UILabel()
        setupClip(label: clipEndLabel)
        addSubview(clipEndLabel)
        
        layoutSliders()
    }
    
    private func layoutSliders(withClipSliders: Bool = true) {
        let rect = bounds.inset(by: controlInset)
        var sliderRect = rect.inset(by: sliderInset)
        let sliderHeight: CGFloat = 40
        if model.durationF > 0 {
            let w = sliderRect.width - thumbSize.width
            let l = w * CGFloat(model.startOffsetF) / CGFloat(model.durationF)
            let r = w * CGFloat(model.endOffsetF) / CGFloat(model.durationF)
            sliderRect = sliderRect.inset(left: l, right: r)
            sliderRect = sliderRect.roundRect()
        }
        
        if lastSliderRect != sliderRect {
            lastSliderRect = sliderRect
            topSlider.frame = CGRect(x: sliderRect.minX, y: sliderRect.minY - sliderHeight/2, width: sliderRect.width, height: sliderHeight)
            botSlider.frame = CGRect(x: sliderRect.minX, y: sliderRect.maxY - sliderHeight/2, width: sliderRect.width, height: sliderHeight)
            updateEase(label: topLabel)
            updateEase(label: botLabel)
        }
        
        if withClipSliders {
            let clipRect = rect.inset(by: sliderClipInset)
            clipBeginSlider.frame = clipRect
            clipEndSlider.frame = clipRect
            updateClip(label: clipEndLabel)
            updateClip(label: clipBeginLabel)
        }
    }
    
    @objc func sliderChanges(_ slider: UISlider) {
        // TODO: think about model binding
        innerChangeModel = true
        if slider == topSlider {
            model.endEase = CGFloat(1 - slider.value)
            updateCurve()
            updateEase(label: topLabel)
        } else if slider == botSlider {
            model.startEase = CGFloat(slider.value)
            updateCurve()
            updateEase(label: botLabel)
        } else if slider == clipBeginSlider {
            if !slider.isTracking {
                slider.value = round(slider.value)
            }
            
            var val = CGFloat(slider.value)
            if val + round(model.endOffsetF) + minTimeDistF > model.durationF {
                val = model.durationF - round(model.endOffsetF) - minTimeDistF
                slider.value = Float(val)
            }
            model.startOffsetF = CGFloat(slider.value)
            layoutSliders(withClipSliders: false)
            updateCurve()
            updateClip(label: clipBeginLabel)
        } else if slider == clipEndSlider {
            if !slider.isTracking {
                slider.value = round(slider.value)
            }
            var val = CGFloat(slider.maximumValue - slider.value)
            if val + round(model.startOffsetF) + minTimeDistF > model.durationF {
                val = model.durationF - round(model.startOffsetF) - minTimeDistF
                slider.value = slider.maximumValue - Float(val)
            }
            model.endOffsetF = val
            layoutSliders(withClipSliders: false)
            updateCurve()
            updateClip(label: clipEndLabel)
        }
        innerChangeModel = false
    }
}

// MARK: - Labels
fileprivate extension TimingControl {
    
    func setupEase(label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor(red:0.18, green:0.49, blue:0.96, alpha:1.00)
        label.textAlignment = .center
        label.frame = CGRect(origin: .zero, size: CGSize(width: 80, height: 20))
    }
    
    func updateEase(label: UILabel) {
        let isTop = label == topLabel
        let slider: TimingSlider = isTop ? topSlider : botSlider
        let progress = isTop ? (1-topSlider.value) : botSlider.value
        let percent = Int(round(100 * progress))
        label.text = "\(percent)%"
        let thumbRect = slider.convert(slider.thumbRect, to: self)
        
        let halfHeight = label.frame.height / 2.0
        let y = isTop ? thumbRect.minY-halfHeight : thumbRect.maxY+halfHeight
        label.center = CGPoint(x: thumbRect.midX, y: y)
    }
    
    func setupClip(label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor(red:0.98, green:0.84, blue:0.32, alpha:1.00)
        label.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 20))
    }
    
    func updateClip(label: UILabel) {
        let isBegin = label == clipBeginLabel
        let slider: TimeClipSlider = isBegin ? clipBeginSlider : clipEndSlider
        let value = Int(round(slider.value))
        label.text = "\(value)f"
        let thumbRect = slider.convert(slider.thumbRect, to: self)
        
        var labFrame = label.frame
        labFrame.origin.x = thumbRect.maxX
        labFrame.origin.y = thumbRect.midY - labFrame.height / 2.0
        let labelVisible: Bool
        if isBegin {
            labelVisible = labFrame.maxX < clipEndLabel.frame.minX
        } else {
            labelVisible = bounds.contains(labFrame)
        }
        if labelVisible {
            label.frame = labFrame
            label.textAlignment = .left
        } else {
            labFrame.origin.x = thumbRect.minX - labFrame.width
            label.frame = labFrame
            label.textAlignment = .right
        }
    }
}
