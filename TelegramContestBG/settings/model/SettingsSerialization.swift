//
//  SettingsSerialization.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 29.01.2021.
//

import UIKit


public extension ChatAnimationSettingsModel {
    
    static func fromDefaults(key: String = "ChatAnimationSettings") -> ChatAnimationSettingsModel {
        let defaults = UserDefaults.standard
        if let savedSett = defaults.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(ChatAnimationSettingsModel.self, from: savedSett) {
                return loaded
            }
        }
        return ChatAnimationSettingsModel()
    }
    
    func saveToDefaults(key: String = "ChatAnimationSettings") {
        if let encoded = try? JSONEncoder().encode(self) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
        Self.shared.backgroundColors = backgroundColors
        Self.shared.messages = messages
    }
    
    func saveToDocuments() -> String? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let savePath = (documentsPath as NSString).appendingPathComponent("chat_animation_settings.json")
        if let _ = try? JSONEncoder().encode(self).write(to: URL(fileURLWithPath: savePath)) {
            return savePath
        }
        return nil
    }
    
    func loadFrom(url: URL) -> NSError? {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: url) else {
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't access to file"])
        }
        guard let loaded = try? decoder.decode(ChatAnimationSettingsModel.self, from: data) else {
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't parse file"])
        }
        
        self.backgroundColors = loaded.backgroundColors
        self.messages = loaded.messages
        return nil
    }
}
