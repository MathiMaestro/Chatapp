//
//  ChatVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 02/10/22.
//

import UIKit

class ChatVC: NCLoadingVC {
    
    var chat : Chat
    var dataSource : UITableViewDiffableDataSource<String,Message>?
    var taxtFieldBottomAnchor: NSLayoutConstraint?
    
    private var messageData     = MessagesOrderedData()
    private let chatTextView    = NCChatTextView(frame: .zero)
    
    private let tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ChatViewTaleViewCell.self, forCellReuseIdentifier: ChatViewTaleViewCell.reusableId)
        tableView.showsVerticalScrollIndicator  = false
        tableView.separatorStyle                = .none
        
        return tableView
    }()
    
    init(chat: Chat) {
        self.chat     = chat
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureUI()
        configureNotificationObserver()
        showLoadingView()
        getChatData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatVC {
    
    private func configureUI() {
        view.backgroundColor            = .systemBackground
        tableView.backgroundColor       = .secondarySystemBackground
        
        view.addSubViews(tableView,chatTextView)
        
        NSLayoutConstraint.activate([
            chatTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            chatTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            chatTextView.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: chatTextView.topAnchor)
        ])
        
        tableView.delegate      = self
        chatTextView.delegate   = self
        taxtFieldBottomAnchor   = chatTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        taxtFieldBottomAnchor?.isActive = true
        
        configureDataSource()
    }
    
    private func configureNavBar() {
        navigationItem.largeTitleDisplayMode    = .never
        tabBarController?.tabBar.isHidden       = true
        navigationController?.navigationBar.backgroundColor = .systemBackground
        preparenavigationTitleView()
    }
    
    private func preparenavigationTitleView() {
        guard let sender = chat.getSender() else { return }
        
        let navBarTitleView = NCNavbarProfileTitleView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        navBarTitleView.updateView(with: sender)
        navigationItem.titleView = navBarTitleView
    }
    
    private func getChatData() {
        ChatNetworkManager.shared.getMessages(chatId: chat._id, limit: 100) { [unowned self] result in
            switch result {
            case .success(let messageData):
                self.messageData = messageData
                self.dismissLoadingView()
                self.updateView()
            case .failure(let error):
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
}

extension ChatVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return getSectionHeaderView(sectionName: messageData.sectionOrder[section])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatTextView.endEditing(force: true)
    }
    
    private func getSectionHeaderView(sectionName: String) -> UIView? {
        let headerView = NCChatSectionHeaderView()
        headerView.updateLabel(with: sectionName)
        return headerView
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { (tableView, indexPath, message) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatViewTaleViewCell.reusableId, for: indexPath) as? ChatViewTaleViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: ChatViewTaleViewCell.reusableId, for: indexPath)
            }
            cell.updateView(for: message)
            return cell
        })
    }
    
    private func updateView() {
        var snapShot = NSDiffableDataSourceSnapshot<String,Message>()
        snapShot.appendSections(messageData.sectionOrder)
        for section in messageData.sectionOrder {
            if let messages = messageData.sectionData[section] {
                snapShot.appendItems(messages, toSection: section)
            }
        }
        DispatchQueue.main.async { self.dataSource?.apply(snapShot, animatingDifferences: false, completion: {
            self.scrollToLast()
        }) }
    }
    
    private func scrollToLast() {
        guard let lastSectionDate = self.messageData.sectionOrder.last,let lastSection = self.messageData.sectionData[lastSectionDate], lastSection.count > 0, self.messageData.sectionOrder.count > 0 else { return }
        self.tableView.scrollToRow(at: IndexPath(row: (lastSection.count - 1), section: (self.messageData.sectionOrder.count - 1)), at: .bottom, animated: false)
    }
}

extension ChatVC {
    
    private func configureNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandling(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandling(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
    @objc func keyboardHandling(notification: Notification) {
        guard let userInfo = notification.userInfo, let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let isKeyBoardShowing = notification.name == UIResponder.keyboardWillShowNotification
        taxtFieldBottomAnchor?.constant = isKeyBoardShowing ? -frame.height : 0
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.scrollToLast()
        }
    }
}

extension ChatVC : NCChatTextViewToViewProtocal {
    
    func sendButtonTaped() {
        
    }
}
