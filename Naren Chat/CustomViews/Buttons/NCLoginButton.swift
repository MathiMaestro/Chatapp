//
//  NCLoginButton.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 12/09/22.
//

import UIKit

class NCButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    convenience init(buttonTitle: String, buttonColor: UIColor) {
        self.init(frame: .zero)
        set(title: buttonTitle)
        set(buttonColor: buttonColor)
    }
    
    convenience init(buttonColor: UIColor) {
        self.init(frame: .zero)
        set(buttonColor: buttonColor)
    }
    
    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius      = 10
        titleLabel?.font        = UIFont.preferredFont(forTextStyle: .headline)
        setTitleColor(.white, for: .normal)
    }
    
    func set(buttonColor: UIColor) {
        backgroundColor = buttonColor
    }
    
    func set(title: String) {
        setTitle(title, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
