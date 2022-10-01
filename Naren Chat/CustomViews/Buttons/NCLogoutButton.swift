//
//  NCLogoutButton.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 02/10/22.
//

import UIKit

class NCLogoutButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureProperties()
    }
    
    private func configureProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "power")
        setImage(image, for: .normal)
        contentHorizontalAlignment  = .fill
        contentVerticalAlignment    = .fill
        tintColor                   = .systemRed
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
