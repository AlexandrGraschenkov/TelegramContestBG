//
//  ColorSelectionCell.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 28.01.2021.
//

import UIKit

class ColorSelection: UITextField {
    private var textCheckDelegate: ColorSelectionDelegate?
    private var _color: UIColor = .white
    private var inset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
    var onChange: ((UIColor)->())? = nil
    var color: UIColor {
        set {
            updateColor(color: newValue)
            updateText()
        }
        get {
            return _color
        }
    }
    
    func setup(force: Bool = false) {
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        
        if delegate != nil { return }
        
        returnKeyType = .done
        autocapitalizationType = .allCharacters
        autocorrectionType = .no
        textCheckDelegate = ColorSelectionDelegate()
        textCheckDelegate?.onTextChange = {[weak self] text in
            if let newColor = UIColor(hex: text) {
                self?.updateColor(color: newColor)
                self?.onChange?(newColor)
            }
        }
        delegate = textCheckDelegate
        borderStyle = .none
        font = UIFont(name: "Menlo-Regular", size: 17)
        updateText()
        updateColor(color: _color)
    }
    
    fileprivate func updateText() {
        text = "#" + _color.hex()
        textColor = _color.isLight() ? UIColor.black : UIColor.white
    }
    
    private func updateColor(color newColor: UIColor) {
        _color = newColor.withAlphaComponent(1)
        textColor = _color.isLight() ? UIColor.black : UIColor.white
        self.backgroundColor = _color
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: inset)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: inset)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: inset)
    }
}


class ColorSelectionDelegate: NSObject, UITextFieldDelegate {
    var allowSymbols = CharacterSet(charactersIn: "#ABCDEF0123456789")
    var onTextChange: ((String)->())?
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let ch = CharacterSet(charactersIn: string)
        var ok = ch.isSubset(of: allowSymbols)
        if !ok {
            return false
        }
        
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        ok = ok && text.hasPrefix("#")
        ok = ok && text.lengthOfBytes(using: .utf8) <= 7
        
        if ok {
            onTextChange?(text)
        }
        return ok
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        (textField as? ColorSelection)?.updateText()
        return true
    }
}


