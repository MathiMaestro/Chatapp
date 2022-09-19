//
//  NCTextField.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 10/09/22.
//

import UIKit

class NCTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureProperties()
    }
    
    convenience init(placeHolderName: String) {
        self.init(frame: .zero)
        configurePropertyWith(placeHolderName: placeHolderName)
    }
    
    private func configureProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius      = 10
        layer.borderWidth       = 2
        layer.borderColor       = UIColor.systemGray4.cgColor
            
        textColor               = .label
        tintColor               = .label
        textAlignment           = .center
            
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
        setupVisiblityButton()
    }
    
    private func setupVisiblityButton() {
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
