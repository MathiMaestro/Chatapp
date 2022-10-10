//
//  NCChatSectionHeaderView.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 10/10/22.
//

import UIKit

class NCChatSectionHeaderView : UIView {
    
    private let label = NCTableSectionLabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureUI()
    }
    
    private func configureUI() {
        
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func updateLabel(with text: String) {
        label.setText(with: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
