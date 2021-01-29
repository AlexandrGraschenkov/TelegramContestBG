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

enum TimingModelName: String, Codable {
    case background = "background"
    case xPos = "x_position"
    case yPos = "y_position"
    case bubbleShape = "bubble_shape"
    case textPosition = "text_position"
    case colorChange = "color_change"
    case timeAppears = "time_appears"
    case scale = "scale"
}

struct ChatMessagesAnimModel: Codable {
    var shortName: String
    var fullName: String
    var timing: [TimingModelName: TimingModel]
    
    mutating func update(duration: TimingTime) {
        for (k, _) in timing {
            timing[k]?.update(duration: duration.float)
        }
    }
}

class ChatAnimationSettingsModel: Codable {
    var backgroundColors: [String]
    var messages: [MessagesKey: ChatMessagesAnimModel]
    
    func clone() -> ChatAnimationSettingsModel {
        let cl = ChatAnimationSettingsModel()
        cl.backgroundColors = backgroundColors
        cl.messages = messages
        return cl
    }
    
    init() {
        backgroundColors = Self.defaultBackgroundColors
        messages = Self.defaultMessages
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MessagesKey.self)
        backgroundColors = try container.decode([String].self, forKey: .backgroundColors)
        messages = [:]
        
        for k in MessagesKey.allMessage {
            messages[k] = (try? container.decode(ChatMessagesAnimModel.self, forKey: k)) ?? Self.defaultMessages[k]
        }
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MessagesKey.self)
        try container.encode(backgroundColors, forKey: .backgroundColors)
        for (key, val) in messages {
            try container.encode(val, forKey: key)
        }
    }
    
    
    enum MessagesKey: String, CodingKey {
        case backgroundColors, background, smallMessage, bigMessage, linkPreview, singleEmoji, sticker, voiceMessage, videoMessage
        
        static let allMessage: [MessagesKey] = [.background, .smallMessage, .bigMessage, .linkPreview, .singleEmoji, .sticker, .voiceMessage, .videoMessage]
    }
    
    private static let defaultMessages: [MessagesKey: ChatMessagesAnimModel] = [
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
