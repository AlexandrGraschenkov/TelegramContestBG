//
//  ChatAnimationSettingsModel.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 26.01.2021.
//

import UIKit


enum TimingTime: Int, CaseIterable {
    case _30f = 30
    case _45f = 45
    case _60f = 60
    
    func display() -> String {
        switch self {
        case ._60f: return "60f (1 sec)"
        default: return "\(rawValue)f"
        }
    }
    var float: CGFloat { return CGFloat(rawValue) }
    
    static func fromFloat(_ val: CGFloat?) -> TimingTime {
        let val = TimingTime(rawValue: Int(val ?? 60)) ?? ._60f
        return val
    }
}

enum GAAnimElemName: String, Codable {
    case background = "background"
    case xPos = "x_position"
    case yPos = "y_position"
    case bubbleShape = "bubble_shape"
    case textPosition = "text_position"
    case colorChange = "color_change"
    case timeAppears = "time_appears"
    case scale = "scale"
}

public struct GAAnimObjectModel: Codable {
    var shortName: String
    var fullName: String
    var timing: [GAAnimElemName: GATimingModel]
    
    mutating func update(duration: TimingTime) {
        for (k, _) in timing {
            timing[k]?.update(duration: duration.float)
        }
    }
}

public class GAChatAnimModel: Codable {
    public var backgroundColorsHex: [String]
    public var objects: [ObjectKey: GAAnimObjectModel]
    
    public func clone() -> GAChatAnimModel {
        let cl = GAChatAnimModel()
        cl.backgroundColorsHex = backgroundColorsHex
        cl.objects = objects
        return cl
    }
    
    static let shared = fromDefaults()
    static fileprivate(set) var changeSubscribers: [String: (GAChatAnimModel)->()] = [:]
    
    init() {
        backgroundColorsHex = Self.defaultBackgroundColors
        objects = Self.defaultMessages
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ObjectKey.self)
        backgroundColorsHex = try container.decode([String].self, forKey: .backgroundColors)
        objects = [:]
        
        for k in ObjectKey.allMessage {
            objects[k] = (try? container.decode(GAAnimObjectModel.self, forKey: k)) ?? Self.defaultMessages[k]
        }
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ObjectKey.self)
        try container.encode(backgroundColorsHex, forKey: .backgroundColors)
        for (key, val) in objects {
            try container.encode(val, forKey: key)
        }
    }
    
    
    public enum ObjectKey: String, CodingKey {
        case backgroundColors, background, smallMessage, bigMessage, linkPreview, singleEmoji, sticker, voiceMessage, videoMessage
        
        static let allMessage: [ObjectKey] = [.background, .smallMessage, .bigMessage, .linkPreview, .singleEmoji, .sticker, .voiceMessage, .videoMessage]
    }
    
    private static let defaultMessages: [ObjectKey: GAAnimObjectModel] = [
        .background: .defaultBackground,
        .smallMessage: .defaultSmallMessage,
        .bigMessage: .defaultBigMessage,
        .linkPreview: .defaultLinkPreview,
        .singleEmoji: .defaultSingleEmoji,
        .sticker: .defaultSticker,
        .voiceMessage: .defaultVoiceMessage,
        .videoMessage: .defaultVideoMessage,
    ]
    private static let defaultBackgroundColors = ["FFF6BF", "76A076", "F6E477", "316B4D"]
}

extension GAChatAnimModel {
    public var backgroundColors: [UIColor] {
        return backgroundColorsHex.map({UIColor(hex: $0) ?? .white})
    }
}


extension GAChatAnimModel {
    static private func randomString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let key = String((0..<10).map{ _ in letters.randomElement()! })
        return key
    }
    
    static func subscribeSharedChange(_ closure: @escaping (GAChatAnimModel)->()) -> ()->() {
        var key = randomString()
        while changeSubscribers[key] != nil {
            key = randomString()
        }
        changeSubscribers[key] = closure
        return { self.changeSubscribers[key] = nil }
    }
    
    var backgroundTiming: GATimingModel {
        return objects[.background]!.timing[.background]!
    }
}
