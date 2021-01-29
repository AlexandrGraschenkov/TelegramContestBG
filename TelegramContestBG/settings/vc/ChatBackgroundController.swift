//
//  ChatBackgroundController.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 29.01.2021.
//

import UIKit

class ChatBackgroundController: UIViewController {

    @IBOutlet var display: ChatBackground!
    var settings: ChatAnimationSettingsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        display.colors = settings.backgroundColorsValues
        if let t = settings.messages[.background]?.timing[.background] {
            display.timing = t
        }
        
        navigationItem.title = "Background"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func animate() {
        display.runNextAnim()
    }

}
