//
//  ChatBackgroundController.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 29.01.2021.
//

import UIKit

class ChatBackgroundController: UIViewController {
    
    var display: GAChatBackground!
    var botView: UIVisualEffectView!
    var settings: GAChatAnimModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        display = GAChatBackground(frame: view.bounds)
        display.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(display)
        
        display.colors = settings.backgroundColors
        if let t = settings.objects[.background]?.timing[.background] {
            display.timing = t
        }
        
        initBottomView()
        
        navigationItem.title = "Background"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
    
    func initBottomView() {
        var style: UIBlurEffect.Style = .extraLight
        if #available(iOS 13.0, *) {
            style = .systemChromeMaterial
        }
        botView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        botView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        botView.frame = CGRect(x: 0, y: 0, width: 320, height: 90)
        view.addSubview(botView)
        
        let butt = UIButton(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        butt.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        butt.addTarget(self, action: #selector(animate), for: .touchUpInside)
        butt.setTitle("Animate", for: .normal)
        butt.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        butt.setTitleColor(.systemBlue, for: .normal)
        botView.contentView.addSubview(butt)
        
        layoutBot()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutBot()
    }
    
    func layoutBot() {
        let fr = view.bounds
        let h = insets.bottom + 50
        botView.frame = CGRect(x: 0, y: fr.height - h, width: fr.width, height: h)
    }
    
    @objc func animate() {
        display.runNextAnim()
    }
 
    var insets: UIEdgeInsets {
        let w: UIWindow?
        if #available(iOS 13.0, *) {
            w = UIApplication.shared.windows[0]
        } else {
            w = UIApplication.shared.keyWindow
        }
        var inset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        if #available(iOS 11.0, *) {
            inset.top = w?.safeAreaInsets.top ?? inset.top
            inset.bottom = w?.safeAreaInsets.bottom ?? inset.bottom
            inset.left = w?.safeAreaInsets.left ?? inset.left
            inset.right = w?.safeAreaInsets.right ?? inset.right
        }
        return inset
    }
}
