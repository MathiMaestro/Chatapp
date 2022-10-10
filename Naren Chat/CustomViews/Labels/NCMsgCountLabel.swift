//
//  NCMsgCountLabel.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 01/10/22.
//

import UIKit

class NCMsgCountLabel: UILabel {

    let edgeInset = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureProperties()
    }
    
    convenience init(textColor: UIColor, textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        set(textColor: textColor, textAlignment: textAlignment)
    }
    
    private func configureProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        
        font                    = .preferredFont(forTextStyle: .callout)
        lineBreakMode           = .byTruncatingTail
        numberOfLines           = 1
        backgroundColor         = .systemBlue
        layer.cornerRadius      = 7
        layer.masksToBounds     = true
    }
    
    private func set(textColor: UIColor, textAlignment: NSTextAlignment) {
        self.textColor      = textColor
        self.textAlignment  = textAlignment
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + edgeInset.left + edgeInset.right, height: size.height + edgeInset.top + edgeInset.bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
