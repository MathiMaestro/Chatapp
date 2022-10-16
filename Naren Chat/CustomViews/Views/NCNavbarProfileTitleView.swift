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
    private let statusLabel         = NCBodyLabel(textColor: .systemBlue, textAlignment: .left,font: .preferredFont(forTextStyle: .caption1),title: "typing...")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.addSubViews(profileImageView,titleLabel,statusLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 6),
            
            statusLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 3)
            
        ])
    }
    
    func updateView(with sender: Participant) {
        profileImageView.downloadImage(for: sender.imgUrl)
        titleLabel.text = sender.userName
    }
    
    func updateStatus(type: ChatStatus) {
        switch type {
        case .typing:
            statusLabel.text = "typing..."
            statusLabel.textColor = .systemGray2
        case .online:
            statusLabel.text = "online"
            statusLabel.textColor = .systemGreen
        case .offline(var time):
            let dateTime = time.split(separator: ",")
            statusLabel.text = "last scene \(dateTime.first ?? "") at \(dateTime.last ?? "")"
            statusLabel.textColor = .systemGray2
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return frame.size
    }
    
}

enum ChatStatus {
    case typing
    case online
    case offline(time: String)
}
