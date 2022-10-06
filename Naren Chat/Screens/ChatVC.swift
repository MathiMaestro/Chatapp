//
//  ChatVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 02/10/22.
//

import UIKit

class ChatVC: UIViewController {
    
    var chat : Chat
    
    var messages: [Message]     = []
    var hasMoreMessage: Bool    = false
    
    private let tableView : UIView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ChatViewTaleViewCell.self, forCellReuseIdentifier: ChatViewTaleViewCell.reusableId)
        return tableView
    }()
    
    init(chat: Chat) {
        self.chat     = chat
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureUI()
        getChatData()
    }
 
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    private func configureNavBar() {
        navigationItem.largeTitleDisplayMode    = .never
        navigationItem.title                    = chat.getSender()?.userName ?? "Unknown"
    }
    
    private func getChatData() {
        ChatNetworkManager.shared.getMessages(chatId: chat._id, limit: 100) { [unowned self] result in
            switch result {
            case .success(let messageData):
                self.hasMoreMessage = messageData.hasMore
                self.messages       = messageData.messages
            case .failure(let error):
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    private func updateView() {
        
    }
}

class ChatViewTaleViewCell : UITableViewCell {
    
    static let reusableId = "NCChatViewTaleViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
