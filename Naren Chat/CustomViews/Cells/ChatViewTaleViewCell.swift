//
//  ChatViewTaleViewCell.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 09/10/22.
//

import UIKit


class ChatViewTaleViewCell : UITableViewCell {
    
    static let reusableId = "NCChatViewTaleViewCell"
    
    private let messageLabel    = NCBodyLabel(textColor: .label, textAlignment: .left)
    private let timeLabel       = NCBodyLabel(textColor: .secondaryLabel, textAlignment: .right, font: .preferredFont(forTextStyle: .footnote))
    
    private let containerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var messageLabelLeadingAnchor : NSLayoutConstraint?
    private var messageLabelTrailingAnchor : NSLayoutConstraint?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = ""
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        configureUI()
        configureProperties()
    }
    
    private func configureProperties() {
        selectionStyle                      = .none
        contentView.backgroundColor         = .secondarySystemBackground
        containerView.layer.cornerRadius    = 10
    }
    
    private func configureUI() {
        contentView.addSubViews(containerView,messageLabel,timeLabel)
        
        messageLabel.preferredMaxLayoutWidth = contentView.frame.width * 0.85
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 15),
            messageLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -25),
            
            timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 3),
            timeLabel.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: -3),
            timeLabel.heightAnchor.constraint(equalToConstant: 16),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 7),
            containerView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -3),
            containerView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 10)
        ])
        
        messageLabelLeadingAnchor = messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 26)
        messageLabelLeadingAnchor?.isActive = true
        
        messageLabelTrailingAnchor = messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -26)
        messageLabelTrailingAnchor?.isActive = false
        
        messageLabel.numberOfLines = 0
    }
    
    func updateView(for message: Message) {
        messageLabel.text                       = message.text
        timeLabel.text                          = message.time?.convertToDate()?.convertToTimeString()
        messageLabelLeadingAnchor?.isActive     = message.isReceived()
        messageLabelTrailingAnchor?.isActive    = !message.isReceived()
        containerView.backgroundColor           = message.isReceived() ? UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1) : UIColor(red: 45/255, green: 108/255, blue: 233/255, alpha: 1)
        messageLabel.textColor                  = message.isReceived() ? .black : .white
        timeLabel.textColor                     = message.isReceived() ? .black.withAlphaComponent(0.6) : UIColor.init(white: 0.9, alpha: 1)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
