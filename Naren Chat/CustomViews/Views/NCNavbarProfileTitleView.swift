//
//  NCNavbarProfileTitleView.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 10/10/22.
//

import UIKit


class NCNavbarProfileTitleView : UIView {
    
    private let titleLabel          = NCTitleLabel(textColor: .label, textAlignment: .left, font: .preferredFont(forTextStyle: .headline))
    private let profileImageView    = NCProfileImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.addSubViews(profileImageView,titleLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func updateView(with sender: Participant) {
        profileImageView.downloadImage(for: sender.imgUrl)
        titleLabel.text = sender.userName
    }
    
    override var intrinsicContentSize: CGSize {
        return frame.size
    }
    
}
