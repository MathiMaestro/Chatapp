//
//  NCImageView.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 17/10/22.
//

import UIKit

class NCMessageSentImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureProperties()
    }
    
    private func configureProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        
        tintColor   = .secondaryLabel
        contentMode = .scaleAspectFill
    }
    
    func updateImage(IsRead: Bool) {
        image = IsRead ? #imageLiteral(resourceName: "icons8-double-tick.png") : #imageLiteral(resourceName: "icons8-done.png")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
