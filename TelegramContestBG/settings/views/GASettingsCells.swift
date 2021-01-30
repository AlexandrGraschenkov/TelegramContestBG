//
//  SettingsCells.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 28.01.2021.
//

import UIKit

let GADefaultCellHeight: CGFloat = 46

class GACell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
    }
}

class GABackgroundCell: GACell {
    var displayView: GAChatBackground!
    var openButton: UIButton!
    var openPressed: (()->())?
    
    override func setup() {
        selectionStyle = .none
        let fr = CGRect(x: 0, y: 0, width: 320, height: 300)
        contentView.frame = fr
        
        displayView = GAChatBackground(frame: fr.inset(bottom: GADefaultCellHeight))
        displayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(displayView)
        
        openButton = UIButton(frame: fr.inset(top: displayView.frame.height))
        openButton.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        openButton.addTarget(self, action: #selector(openPressedAction), for: .touchUpInside)
        openButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        openButton.setTitleColor(.systemBlue, for: .normal)
        openButton.setTitle("Open Full Screen", for: .normal)
        openButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        openButton.contentHorizontalAlignment = .left
        contentView.addSubview(openButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(displayPressedAction))
        displayView.isUserInteractionEnabled = true
        displayView.addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        openPressed = nil
    }
    
    @objc func openPressedAction() {
        openPressed?()
    }
    
    @objc func displayPressedAction() {
        displayView.runNextAnim()
//        displayPressed?()
    }
}

// MARK: - Timing
class GATimingCell: GACell {
    var timingView: GATimingControl!
    var modelName: GAAnimElemName?
    
    override func setup() {
        let fr = CGRect(x: 0, y: 0, width: 320, height: 300)
        contentView.frame = fr
        
        timingView = GATimingControl(frame: fr)
        timingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(timingView)
        selectionStyle = .none
    }
    
    func setup(name: GAAnimElemName, timing: GATimingModel) {
        timingView.model = timing
        modelName = name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        modelName = nil
    }
}

// MARK: - Color
class GAColorSelectionCell: GACell {

    var colorView: GAColorSelection!
//    var nameLabel: UILabel!
    
    var color: UIColor {
        return colorView.color
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setup() {
        selectionStyle = .none
        let fr = CGRect(x: 0, y: 0, width: 320, height: GADefaultCellHeight)
        contentView.frame = fr
        
        var colorFrame = CGRect(x: 0, y: 0, width: 90, height: 34)
        colorFrame.origin.x = fr.maxX - 16 - colorFrame.width
        colorFrame.origin.y = (fr.maxY - colorFrame.height) / 2
        colorView = GAColorSelection(frame: colorFrame)
        colorView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        contentView.addSubview(colorView)
    }
    
    func setup(name: String, color: UIColor) {
        colorView.setup(force: true)
        textLabel?.text = name
        colorView.color = color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            colorView.becomeFirstResponder()
        }
    }
}

// MARK: - Action
class GAActionCell: GACell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    override func setup() {
        detailTextLabel?.textColor = UIColor.lightGray
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
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
