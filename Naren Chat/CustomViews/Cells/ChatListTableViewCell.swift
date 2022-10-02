//
//  ChatListTableViewCell.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 28/09/22.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {
    
    static let reusableId = "ChatListTableViewCell"
    
    private let profileImageView        = NCProfileImageView(frame: .zero)
    private let userNameLabel           = NCTitleLabel(textColor: .label, textAlignment: .left,font: .preferredFont(forTextStyle: .headline))
    private let lastMessageLabel        = NCBodyLabel(textColor: .secondaryLabel, textAlignment: .left,font: .preferredFont(forTextStyle: .subheadline))
    private let timeLabel               = NCBodyLabel(textColor: .secondaryLabel, textAlignment: .right,font: .preferredFont(forTextStyle: .subheadline))
    private let unReadChatCountLabel    = NCMsgCountLabel(textColor: .white, textAlignment: .center)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userNameLabel.text          = nil
        lastMessageLabel.text       = nil
        timeLabel.text              = nil
        unReadChatCountLabel.text   = nil
        
        profileImageView.resetImage()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    private func configureUI() {
        contentView.addSubViews(profileImageView,userNameLabel,lastMessageLabel,timeLabel,unReadChatCountLabel)
        
        let padding : CGFloat = 10
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 44),
            profileImageView.widthAnchor.constraint(equalToConstant: 44),
            
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: padding),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -padding),
            timeLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            
            unReadChatCountLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor,constant: 10),
            unReadChatCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -padding),
            
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            userNameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -padding),
            
            lastMessageLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            lastMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 6),
            lastMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70),
        ])
        
        profileImageView.layer.cornerRadius     = 22
        profileImageView.layer.masksToBounds    = true
    }
    
    func updateView(with chat: Chat) {
        guard let sender = chat.getSender() else { return }
        timeLabel.text              = chat.lastActiveTime.convertToDate()?.convertToString()
        unReadChatCountLabel.text   = chat.unreadCount > 0 ? "\(chat.unreadCount)" : nil
        userNameLabel.text          = sender.userName
        lastMessageLabel.text       = chat.lastMessage.text
        profileImageView.downloadImage(for: sender.imgUrl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}