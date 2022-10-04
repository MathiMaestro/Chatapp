//
//  NCBodyLabel.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 12/09/22.
//

import UIKit

class NCBodyLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureProperties()
    }
    
    convenience init(textColor: UIColor, textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        set(textColor: textColor, textAlignment: textAlignment)
    }
    
    convenience init(textColor: UIColor, textAlignment: NSTextAlignment, title: String) {
        self.init(frame: .zero)
        set(textColor: textColor, textAlignment: textAlignment)
        setTitle(with: title)
    }
    
    convenience init(textColor: UIColor, textAlignment: NSTextAlignment, font: UIFont) {
        self.init(frame: .zero)
        set(textColor: textColor, textAlignment: textAlignment)
        self.font = font
    }
    
    convenience init(textColor: UIColor, textAlignment: NSTextAlignment, font: UIFont, title: String) {
        self.init(frame: .zero)
        set(textColor: textColor, textAlignment: textAlignment)
        setTitle(with: title)
        self.font = font
    }
    
    private func configureProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        
        font                        = .preferredFont(forTextStyle: .body)
        adjustsFontSizeToFitWidth   = true
        minimumScaleFactor          = 0.9
        lineBreakMode               = .byTruncatingTail
    }
    
    private func set(textColor: UIColor, textAlignment: NSTextAlignment) {
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
