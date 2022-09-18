//
//  UIviewExtension.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 14/09/22.
//

import UIKit

extension UIView {
    
    func addSubViews(_ views: UIView...) {
        for view in views { addSubview(view) }
    }
    
    func pinToEdges(of superView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
            self.topAnchor.constraint(equalTo: superView.topAnchor),
            self.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        ])
    }
}
