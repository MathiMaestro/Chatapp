//
//  NCTitleLabel.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 18/09/22.
//

import UIKit

class NCTitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureProperties()
    }
    
    convenience init(textColor: UIColor,textAlignment: NSTextAlignment, title: String) {
        self.init(frame: .zero)
        set(textColor: textColor, textAlignment: textAlignment)
        setTitle(with: title)
    }
    
    convenience init(textColor: UIColor,textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        set(textColor: textColor, textAlignment: textAlignment)
    }
    
    private func configureProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        
        font                        = .preferredFont(forTextStyle: .title3)
        adjustsFontSizeToFitWidth   = true
        minimumScaleFactor          = 0.9
        lineBreakMode               = .byTruncatingTail
    }
    
    private func set(textColor: UIColor,textAlignment: NSTextAlignment) {
        self.textColor      = textColor
        self.textAlignment  = textAlignment
    }
    
    func setTitle(with title: String) {
        self.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
