//
//  TimingModel.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 16.01.2021.
//

import UIKit

struct TimingModel: Codable {
    static let zero = TimingModel(durationF: 0, startOffsetF: 0, endOffsetF: 0, startEase: 0, endEase: 0)
    
    var durationF: CGFloat // Frames count
    var startOffsetF: CGFloat // Offset frames count
    var endOffsetF: CGFloat // Offset frames count
    var startEase: CGFloat // 0..1
    var endEase: CGFloat // 0..1
    
    var durationSec: Double { return Double(durationF * 60) }
    var startOffsetPercent: CGFloat {
        if durationF > 0 {
            return CGFloat(startOffsetF) / CGFloat(durationF)
        } else {
            return 0
        }
    }
    var endOffsetPercent: CGFloat {
        if durationF > 0 {
            return CGFloat(endOffsetF) / CGFloat(durationF)
        } else {
            return 0
        }
    }
}
