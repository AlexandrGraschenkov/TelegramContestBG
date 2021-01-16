//
//  ViewController.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 16.01.2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var renderView: BGRenderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderView.update(metaballs: generateMetaballs(percent: 0))
    }


    func generateMetaballs(percent: CGFloat) -> [Metaball] {
        return [
            Metaball(color: UIColor.red, pos: CGPoint(x: 0.2, y: 0.2)),
            Metaball(color: UIColor.green, pos: CGPoint(x: 0.8, y: 0.2)),
            Metaball(color: UIColor.blue, pos: CGPoint(x: 0.8, y: 0.8)),
            Metaball(color: UIColor.yellow, pos: CGPoint(x: 0.2, y: 0.8))
        ]
    }
}

