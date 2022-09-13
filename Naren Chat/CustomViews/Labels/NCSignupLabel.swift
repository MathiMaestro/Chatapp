//
//  NCSignupLabel.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 12/09/22.
//

import UIKit

class NCSignupLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureProperties()
    }
    
    convenience init(textColor: UIColor, text: String) {
        self.init(frame: .zero)
        set(textColor: textColor, text: text)
    }
    
    private func configureProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        
        textAlignment               = .center
        font                        = .preferredFont(forTextStyle: .body)
        adjustsFontSizeToFitWidth   = true
        minimumScaleFactor          = 0.9
        lineBreakMode               = .byTruncatingTail
    }
    
    private func set(textColor: UIColor, text: String) {
        self.textColor  = textColor
        self.text       = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
