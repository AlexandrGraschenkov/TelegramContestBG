//
//  TimingModel.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 16.01.2021.
//

import UIKit

struct GATimingModel: Codable {
    static let zero = GATimingModel(durationF: 0, startOffsetF: 0, endOffsetF: 0, startEase: 0, endEase: 0, name: "")
    
    var durationF: CGFloat // Frames count
    var startOffsetF: CGFloat // Offset frames count
    var endOffsetF: CGFloat // Offset frames count
    var startEase: CGFloat // 0..1
    var endEase: CGFloat // 0..1
    
    var name: String
    var durationSec: CGFloat { return durationF / 60 }
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
    
    private enum CodingKeys: String, CodingKey {
        case durationF, startOffsetF, endOffsetF, startEase, endEase, name
    }
    fileprivate var curveCache: GATimingCurve?
    
    mutating func update(duration: CGFloat) {
        startOffsetF = round(startOffsetF * (duration / self.durationF))
        endOffsetF = round(endOffsetF * (duration / self.durationF))
        self.durationF = duration
        if startOffsetF + endOffsetF + 5 > durationF {
            endOffsetF = durationF - startOffsetF - 5
            endOffsetF = max(0, endOffsetF)
        }
        if startOffsetF + endOffsetF + 5 > durationF {
            startOffsetF = durationF - endOffsetF - 5
            startOffsetF = max(0, startOffsetF)
        }
    }
}

extension GATimingModel {
    mutating func process(progress: CGFloat) -> CGFloat {
        let p1 = CGPoint(x: startEase, y: 0)
        let p2 = CGPoint(x: 1-endEase, y: 1)
        if p1 != curveCache?.p1 || p2 != curveCache?.p2 {
            curveCache = GATimingCurve(cp1: p1, cp2: p2)
        }
        
        let clipStart = startOffsetPercent
        let clipEnd = 1-endOffsetPercent
        if progress < clipStart {
            return 0
        } else if progress > clipEnd {
            return 1
        }
        let p = (progress - clipStart) / (clipEnd - clipStart)
        let res = curveCache!.getValue(x: p, duration: durationSec)
        return res
    }
}
