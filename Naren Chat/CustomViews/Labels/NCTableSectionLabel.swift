//
//  NCTableSectionLabel.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 09/10/22.
//

import UIKit

class NCTableSectionLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureProperties()
    }
    
    private func configureProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        
        font                        = .preferredFont(forTextStyle: .callout)
        adjustsFontSizeToFitWidth   = true
        minimumScaleFactor          = 0.9
        lineBreakMode               = .byTruncatingTail
        textColor                   = .systemBackground
        textAlignment               = .center
        backgroundColor             = .label.withAlphaComponent(0.2)
    }
    
    func setText(with text: String) {
        self.text = text
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 6
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 20, height: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
