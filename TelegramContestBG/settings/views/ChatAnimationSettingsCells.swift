//
//  SettingsCells.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 28.01.2021.
//

import UIKit

class BackgroundCell: UITableViewCell {
    @IBOutlet weak var displayView: ChatBackground!
    @IBOutlet weak var openButton: UIButton!
    var openPressed: (()->())?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(displayPressedAction))
        displayView.isUserInteractionEnabled = true
        displayView.addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        openPressed = nil
    }
    
    @IBAction func openPressedAction() {
        openPressed?()
    }
    
    @objc func displayPressedAction() {
        displayView.runNextAnim()
//        displayPressed?()
    }
}

class TimingCell: UITableViewCell {
    @IBOutlet weak var timingView: TimingControl!
    var modelName: TimingModelName?
    
    func setup(name: TimingModelName, timing: TimingModel) {
        timingView.model = timing
        modelName = name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        modelName = nil
    }
}


class ColorSelectionCell: UITableViewCell {

    @IBOutlet weak var colorView: ColorSelection!
    @IBOutlet weak var nameLabel: UILabel!
    
    var color: UIColor {
        return colorView.color
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(name: String, color: UIColor) {
        colorView.setup(force: true)
        nameLabel.text = name
        colorView.color = color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            colorView.becomeFirstResponder()
        }
    }
}

class ActionCell: UITableViewCell {
    var action: (()->())?
    override func prepareForReuse() {
        super.prepareForReuse()
        action = nil
    }
    
    func setup(name: String, detail: String? = nil, color: UIColor? = nil, action: @escaping ()->() = {}) {
        self.action = action
        self.textLabel?.text = name
        self.detailTextLabel?.text = detail
        self.textLabel?.textColor = color ?? .black
    }
}
