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
    }
    
    private func configurePropertyWith(placeHolderName: String) {
        attributedPlaceholder   = NSAttributedString(string: placeHolderName, attributes: [NSAttributedString.Key.foregroundColor : UIColor.placeholderText])
    }
    
    func configureProperty(forPassowrd isPassword : Bool) {
        isSecureTextEntry   = isPassword
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
