//
//  SettingsSerialization.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 29.01.2021.
//

import UIKit


public extension GAChatAnimModel {
    
    static func fromDefaults(key: String = "ChatAnimationSettings") -> GAChatAnimModel {
        let defaults = UserDefaults.standard
        if let savedSett = defaults.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(GAChatAnimModel.self, from: savedSett) {
                return loaded
            }
        }
        return GAChatAnimModel()
    }
    
    func saveToDefaults(key: String = "ChatAnimationSettings") {
        if let encoded = try? JSONEncoder().encode(self) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
        Self.shared.backgroundColorsHex = backgroundColorsHex
        Self.shared.objects = objects
    }
    
    func saveToDocuments() -> URL? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let savePath = (documentsPath as NSString).appendingPathComponent("chat_animation_settings.json")
        let url = URL(fileURLWithPath: savePath)
        if let _ = try? JSONEncoder().encode(self).write(to: url) {
            return url
        }
        return nil
    }
    
    func loadFrom(url: URL) -> NSError? {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: url) else {
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't access to file"])
        }
        guard let loaded = try? decoder.decode(GAChatAnimModel.self, from: data) else {
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't parse file"])
        }
        
        self.backgroundColorsHex = loaded.backgroundColorsHex
        self.objects = loaded.objects
        return nil
    }
}
