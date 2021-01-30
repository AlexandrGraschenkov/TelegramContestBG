//
//  ChatAnimationSettingsModel+Defaults.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 27.01.2021.
//

import UIKit



extension GATimingModel {
    init(name: GAAnimElemName?, time: TimingTime, startOffsetF: CGFloat, endOffsetF: CGFloat, startEase: CGFloat, endEase: CGFloat) {
        self.startOffsetF = startOffsetF
        self.endOffsetF = endOffsetF
        self.startEase = startEase
        self.endEase = endEase
        self.name = name?.rawValue ?? ""
        self.durationF = CGFloat(time.rawValue)
    }
    
    static func genDefault(name: GAAnimElemName?, time: TimingTime = ._60f) -> GATimingModel {
        return GATimingModel(name: name,
                           time: time,
                           startOffsetF: 0,
                           endOffsetF: 0,
                           startEase: 0.33,
                           endEase: 1)
    }
    
    static func genDefaultDict(names: [GAAnimElemName], time: TimingTime = ._60f) -> [GAAnimElemName: GATimingModel] {
        var timings: [GAAnimElemName: GATimingModel] = [:]
        for k in names {
            timings[k] = .genDefault(name: k, time: time)
        }
        return timings
    }
}


extension GAAnimObjectModel {
    
    static var defaultBackground: GAAnimObjectModel {
        let names: [GAAnimElemName] = [.background]
        let timings: [GAAnimElemName: GATimingModel] = GATimingModel.genDefaultDict(names: names, time: ._60f)
        
        return GAAnimObjectModel(shortName: "Background",
                                     fullName: "Background",
                                     timing: timings)
    }
    
    static var defaultSmallMessage: GAAnimObjectModel {
        let names: [GAAnimElemName] = [.xPos, .yPos, .timeAppears, .textPosition, .colorChange, .bubbleShape]
        let timings: [GAAnimElemName: GATimingModel] = GATimingModel.genDefaultDict(names: names, time: ._30f)
        
        return GAAnimObjectModel(shortName: "Small Message",
                                     fullName: "Small Message (fit in the input field)",
                                     timing: timings)
    }
    
    static var defaultBigMessage: GAAnimObjectModel {
        let names: [GAAnimElemName] = [.xPos, .yPos, .timeAppears, .textPosition, .colorChange, .bubbleShape]
        let timings: [GAAnimElemName: GATimingModel] = GATimingModel.genDefaultDict(names: names, time: ._45f)
        
        return GAAnimObjectModel(shortName: "Big Message",
                                     fullName: "Big Message (doesn't fit into the input field)",
                                     timing: timings)
    }
    
    static var defaultLinkPreview: GAAnimObjectModel {
        let names: [GAAnimElemName] = [.xPos, .yPos, .timeAppears, .textPosition, .colorChange, .bubbleShape]
        let timings: [GAAnimElemName: GATimingModel] = GATimingModel.genDefaultDict(names: names, time: ._45f)
        
        return GAAnimObjectModel(shortName: "Link with Preview",
                                     fullName: "Link with Preview",
                                     timing: timings)
    }
    
    static var defaultSingleEmoji: GAAnimObjectModel {
        let names: [GAAnimElemName] = [.xPos, .yPos, .timeAppears, .scale]
        let timings: [GAAnimElemName: GATimingModel] = GATimingModel.genDefaultDict(names: names, time: ._30f)
        
        return GAAnimObjectModel(shortName: "Single Emoji",
                                     fullName: "Single Emoji",
                                     timing: timings)
    }
    
    static var defaultSticker: GAAnimObjectModel {
        let names: [GAAnimElemName] = [.xPos, .yPos, .timeAppears, .scale]
        let timings: [GAAnimElemName: GATimingModel] = GATimingModel.genDefaultDict(names: names, time: ._30f)
        
        return GAAnimObjectModel(shortName: "Sticker",
                                     fullName: "Sticker",
                                     timing: timings)
    }
    
    static var defaultVoiceMessage: GAAnimObjectModel {
        let names: [GAAnimElemName] = [.xPos, .yPos, .timeAppears, .scale]
        let timings: [GAAnimElemName: GATimingModel] = GATimingModel.genDefaultDict(names: names, time: ._30f)
        
        return GAAnimObjectModel(shortName: "Voice Message",
                                     fullName: "Voice Message",
                                     timing: timings)
    }
    
    static var defaultVideoMessage: GAAnimObjectModel {
        let names: [GAAnimElemName] = [.xPos, .yPos, .timeAppears, .scale]
        let timings: [GAAnimElemName: GATimingModel] = GATimingModel.genDefaultDict(names: names, time: ._30f)
        
        return GAAnimObjectModel(shortName: "Video Message",
                                     fullName: "Video Message",
                                     timing: timings)
    }
}
