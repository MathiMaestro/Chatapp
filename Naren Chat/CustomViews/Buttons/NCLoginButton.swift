//
//  NCLoginButton.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 12/09/22.
//

import UIKit

class NCLoginButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    convenience init(buttonTitle: String, buttonColor: UIColor) {
        self.init(frame: .zero)
        set(title: buttonTitle, buttonColor: buttonColor)
    }
    
    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius      = 10
        titleLabel?.font        = UIFont.preferredFont(forTextStyle: .headline)
        setTitleColor(.white, for: .normal)
    }
    
    private func set(title: String, buttonColor: UIColor) {
        setTitle(title, for: .normal)
        backgroundColor = buttonColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
