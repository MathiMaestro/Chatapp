//
//  ContactListTableViewCell.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 02/10/22.
//

import UIKit

class ContactListTableViewCell: UITableViewCell {
    
    static let reusableId = "ContactListTableViewCell"
    
    private let profileImageView        = NCProfileImageView(frame: .zero)
    private let userNameLabel           = NCTitleLabel(textColor: .label, textAlignment: .left,font: .preferredFont(forTextStyle: .headline))
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userNameLabel.text = nil
        profileImageView.resetImage()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    private func configureUI() {
        contentView.addSubViews(profileImageView,userNameLabel)
        
        let padding : CGFloat = 10
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: padding),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 36),
            profileImageView.widthAnchor.constraint(equalToConstant: 36),
            
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: padding),
            userNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
        ])
        
        profileImageView.layer.cornerRadius     = 18
        profileImageView.layer.masksToBounds    = true
    }
    
    func updateView(with userInfo: UserData) {
        userNameLabel.text = userInfo.userName
        profileImageView.downloadImage(for: userInfo.imgUrl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
