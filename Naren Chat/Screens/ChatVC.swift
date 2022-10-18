//
//  ChatVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 02/10/22.
//

import UIKit

class ChatVC: NCLoadingVC {
    
    private var chat : Chat
    private var dataSource : UITableViewDiffableDataSource<String,Message>?
    private var taxtFieldBottomAnchor: NSLayoutConstraint?
    private var navBarTitleView : NCNavbarProfileTitleView?
    
    private let chatTextView                = NCChatTextView(frame: .zero)
    private var currentStatus: ChatStatus   = .none
    
    private let tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ChatViewTaleViewCell.self, forCellReuseIdentifier: ChatViewTaleViewCell.reusableId)
        tableView.showsVerticalScrollIndicator  = false
        tableView.separatorStyle                = .none
        tableView.contentInset                  = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        MessageUtils.shared.reset()
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
        setNavBarAppearance()
        preparenavigationTitleView()
    }
    
    private func setNavBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func preparenavigationTitleView() {
        guard let sender = chat.getSender() else { return }
        
        navBarTitleView = NCNavbarProfileTitleView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        navBarTitleView?.updateView(with: sender)
        handleActiveStatus()
        navigationItem.titleView = navBarTitleView
    }
    
    private func getChatData() {
        MessageUtils.shared.getMessages(chatId: chat._id, limit: 100) { [unowned self] result in
            switch result {
            case .success(_):
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
        return getSectionHeaderView(sectionName: MessageUtils.shared.messageData.sectionOrder[section])
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
        let messageData = MessageUtils.shared.messageData
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
        let messageData = MessageUtils.shared.messageData
        guard let lastSectionDate = messageData.sectionOrder.last,let lastSection = messageData.sectionData[lastSectionDate], lastSection.count > 0, messageData.sectionOrder.count > 0 else { return }
        self.tableView.scrollToRow(at: IndexPath(row: (lastSection.count - 1), section: (messageData.sectionOrder.count - 1)), at: .bottom, animated: false)
    }
}

extension ChatVC {
    
    private func configureNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandling(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandling(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleActiveStatus), name: NotificationObserverName.activeStatusKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTypingStatus(notification:)), name: NotificationObserverName.messageTypingKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMessage(notification:)), name: NotificationObserverName.newMessageKey, object: nil)
    }

    @objc func handleActiveStatus() {
        guard let contact = ContactsUtils.shared.getSenderContact(for: chat)  else { return }

        if contact.isOnline ?? false {
            navBarTitleView?.updateStatus(type: .online)
            currentStatus = .online
        } else {
            let lastActiveTime = contact.lastOnline.convertToDate()?.convertToString() ?? ""
            navBarTitleView?.updateStatus(type: .offline(time: lastActiveTime))
            currentStatus = .offline(time: lastActiveTime)
        }
    }
    
    @objc func handleTypingStatus(notification: Notification) {
        guard let userInfo = notification.userInfo,let chatId = userInfo["chat_id"] as? String, let isTyping = userInfo["is_typing"] as? Bool, chatId == chat._id else { return }
        navBarTitleView?.updateStatus(type: .typing(isTyping: isTyping, status: currentStatus))
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
    
    @objc func handleNewMessage(notification: Notification) {
        guard let userInfo = notification.userInfo,let chatId = userInfo["chatId"] as? String, chatId == chat._id else { return }
        updateView()
        navBarTitleView?.updateStatus(type: .typing(isTyping: false, status: currentStatus))
    }
}

extension ChatVC : NCChatTextViewToViewProtocal {
    
    func sendButtonTaped() {
        
    }
}
