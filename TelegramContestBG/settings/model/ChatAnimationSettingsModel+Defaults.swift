//
//  ChatAnimationSettingsModel+Defaults.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 27.01.2021.
//

import UIKit



extension TimingModel {
    init(name: TimingModelName?, time: TimingTime, startOffsetF: CGFloat, endOffsetF: CGFloat, startEase: CGFloat, endEase: CGFloat) {
        self.startOffsetF = startOffsetF
        self.endOffsetF = endOffsetF
        self.startEase = startEase
        self.endEase = endEase
        self.name = name?.rawValue ?? ""
        self.durationF = CGFloat(time.rawValue)
    }
    
    static func genDefault(name: TimingModelName?, time: TimingTime = ._60f) -> TimingModel {
        return TimingModel(name: name,
                           time: time,
                           startOffsetF: 0,
                           endOffsetF: 0,
                           startEase: 0.33,
                           endEase: 1)
    }
    
    static func genDefaultDict(names: [TimingModelName], time: TimingTime = ._60f) -> [TimingModelName: TimingModel] {
        var timings: [TimingModelName: TimingModel] = [:]
        for k in names {
            timings[k] = .genDefault(name: k, time: time)
        }
        return timings
    }
}


extension ChatMessagesAnimModel {
    
    static var defaultBackground: ChatMessagesAnimModel {
        let names: [TimingModelName] = [.background]
        let timings: [TimingModelName: TimingModel] = TimingModel.genDefaultDict(names: names, time: ._60f)
        
        return ChatMessagesAnimModel(shortName: "Background",
                                     fullName: "Background",
                                     timing: timings)
    }
    
    static var defaultSmallMessage: ChatMessagesAnimModel {
        let names: [TimingModelName] = [.xPos, .yPos, .timeAppears, .textPosition, .colorChange, .bubbleShape]
        let timings: [TimingModelName: TimingModel] = TimingModel.genDefaultDict(names: names, time: ._30f)
        
        return ChatMessagesAnimModel(shortName: "Small Message",
                                     fullName: "Small Message (fit in the input field)",
                                     timing: timings)
    }
    
    static var defaultBigMessage: ChatMessagesAnimModel {
        let names: [TimingModelName] = [.xPos, .yPos, .timeAppears, .textPosition, .colorChange, .bubbleShape]
        let timings: [TimingModelName: TimingModel] = TimingModel.genDefaultDict(names: names, time: ._45f)
        
        return ChatMessagesAnimModel(shortName: "Big Message",
                                     fullName: "Big Message (doesn't fit into the input field)",
                                     timing: timings)
    }
    
    static var defaultLinkPreview: ChatMessagesAnimModel {
        let names: [TimingModelName] = [.xPos, .yPos, .timeAppears, .textPosition, .colorChange, .bubbleShape]
        let timings: [TimingModelName: TimingModel] = TimingModel.genDefaultDict(names: names, time: ._45f)
        
        return ChatMessagesAnimModel(shortName: "Link with Preview",
                                     fullName: "Link with Preview",
                                     timing: timings)
    }
    
    static var defaultSingleEmoji: ChatMessagesAnimModel {
        let names: [TimingModelName] = [.xPos, .yPos, .timeAppears, .scale]
        let timings: [TimingModelName: TimingModel] = TimingModel.genDefaultDict(names: names, time: ._30f)
        
        return ChatMessagesAnimModel(shortName: "Single Emoji",
                                     fullName: "Single Emoji",
                                     timing: timings)
    }
    
    static var defaultSticker: ChatMessagesAnimModel {
        let names: [TimingModelName] = [.xPos, .yPos, .timeAppears, .scale]
        let timings: [TimingModelName: TimingModel] = TimingModel.genDefaultDict(names: names, time: ._30f)
        
        return ChatMessagesAnimModel(shortName: "Sticker",
                                     fullName: "Sticker",
                                     timing: timings)
    }
    
    static var defaultVoiceMessage: ChatMessagesAnimModel {
        let names: [TimingModelName] = [.xPos, .yPos, .timeAppears, .scale]
        let timings: [TimingModelName: TimingModel] = TimingModel.genDefaultDict(names: names, time: ._30f)
        
        return ChatMessagesAnimModel(shortName: "Voice Message",
                                     fullName: "Voice Message",
                                     timing: timings)
    }
    
    static var defaultVideoMessage: ChatMessagesAnimModel {
        let names: [TimingModelName] = [.xPos, .yPos, .timeAppears, .scale]
        let timings: [TimingModelName: TimingModel] = TimingModel.genDefaultDict(names: names, time: ._30f)
        
        return ChatMessagesAnimModel(shortName: "Video Message",
                                     fullName: "Video Message",
                                     timing: timings)
    }
}
