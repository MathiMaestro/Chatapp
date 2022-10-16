//
//  NCTextField.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 10/09/22.
//

import UIKit

class NCTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureProperties()
    }
    
    convenience init(placeHolderName: String) {
        self.init(frame: .zero)
        configurePropertyWith(placeHolderName: placeHolderName)
    }
    
    convenience init(placeHolderName: String, backgroundColor: UIColor) {
        self.init(frame: .zero)
        configurePropertyWith(placeHolderName: placeHolderName)
        self.backgroundColor = backgroundColor
    }
    
    private func configureProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius      = 10
        layer.borderWidth       = 2
        layer.borderColor       = UIColor.systemGray4.cgColor
            
        textColor               = .label
        tintColor               = .label
        textAlignment           = .left
            
        backgroundColor         = .tertiarySystemBackground
        autocorrectionType      = .no
        clearButtonMode         = .whileEditing
        autocapitalizationType  = .none
        isSecureTextEntry       = false
    }
    
    private func configurePropertyWith(placeHolderName: String) {
        attributedPlaceholder   = NSAttributedString(string: placeHolderName, attributes: [NSAttributedString.Key.foregroundColor : UIColor.placeholderText])
    }
    
    func configurePropertyForPassword() {
        self.isSecureTextEntry  = true
        let button              = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.contentMode      = .center
        
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
    
        rightView       = button
        rightViewMode   = .always
    
        button.addTarget(self, action: #selector(showHidePassword(_:)), for: .touchUpInside)
    }
        
    @objc private func showHidePassword(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.isSecureTextEntry = !sender.isSelected
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 40, y: 0, width: 30 , height: bounds.height)
        }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 30))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
