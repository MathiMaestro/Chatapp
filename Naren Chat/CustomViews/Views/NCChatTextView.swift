//
//  NCChatTextView.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 10/10/22.
//

import UIKit

protocol NCChatTextViewToViewProtocal {
    func sendButtonTaped()
}

class NCChatTextView : UIView {
    
    var delegate: NCChatTextViewToViewProtocal?
    
    private let sendButton : UIButton =  {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane.circle.fill"), for: .normal)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let chatTextField = NCTextField(placeHolderName: "Type your message..", backgroundColor: .systemBackground)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        
        self.addSubViews(chatTextField,sendButton)
        
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            sendButton.topAnchor.constraint(equalTo: self.topAnchor,constant: 9),
            sendButton.widthAnchor.constraint(equalToConstant: 34),
            sendButton.heightAnchor.constraint(equalToConstant: 30),
            
            chatTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            chatTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -5),
            chatTextField.topAnchor.constraint(equalTo: self.topAnchor,constant: 8),
            chatTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func endEditing(force editing: Bool) {
        chatTextField.endEditing(editing)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
