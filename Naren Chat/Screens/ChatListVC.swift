//
//  ChatListVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 18/09/22.
//

import UIKit

class ChatListVC: NCLoadingVC {

    enum DiffableDSSectionType { case main }
    
    private var listCount : Int         = 100
    private var isDataAvailable : Bool  = true
    private var isSearchEnabled: Bool   = false
    private var searchBarText: String   = ""
    private var isFirstTime : Bool      = true
    
    private let tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundColor = .systemBackground
        tableView.register(ChatListTableViewCell.self, forCellReuseIdentifier: ChatListTableViewCell.reusableId)
        tableView.rowHeight = 66
        tableView.allowsMultipleSelectionDuringEditing = true
        return tableView
    }()
    
    private var dataSource : UITableViewDiffableDataSource<DiffableDSSectionType,Chat>?
    
    private var chatList : [Chat]       = []
    private var searchChatList : [Chat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchController()
        configureNotificationObserver()
        configureUI()
        configureDataSource()
        getChatList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden                       = false
        navigationController?.navigationBar.prefersLargeTitles  = true
        if !isFirstTime {
            updateChatList()
        }
        isFirstTime = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: View Configuration
extension ChatListVC {
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Chats"
    }
    
    private func configureSearchController() {
        let searchController                                    = UISearchController()
        searchController.searchBar.placeholder                  = "Search for a username"
        searchController.searchResultsUpdater                   = self
        searchController.obscuresBackgroundDuringPresentation   = false
        navigationItem.searchController                         = searchController
    }
    
    private func configureUI() {
        view.backgroundColor    = .systemBackground
        tableView.frame         = view.bounds
        tableView.delegate      = self
        view.addSubview(tableView)
    }
}

//MARK: Data Configuration
extension ChatListVC {
    
    @objc func getChatList() {
        showLoadingView()
        ChatUtils.shared.getChatList(listCount: listCount) { [unowned self] result in
            self.dismissLoadingView()
            switch result {
            case .success(let chatListData):
                self.chatList           = chatListData.chats
                self.isDataAvailable    = chatListData.hasMore
                self.updateDatasForNewData()
            case .failure(let error):
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
                if error == .invalidToken {
                    SessionUtil.goToLogin()
                }
            }
        }
    }
    
    private func updateDatasForNewData() {
        if isSearchEnabled {
            searchChatList = chatList.filter({($0.getSender()?.userName ?? "").lowercased().contains(searchBarText.lowercased())})
            updateView(chatList: searchChatList)
        } else {
            updateView(chatList: chatList)
        }
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: self.tableView, cellProvider: { [unowned self] (tableView, indexPath, itemIdentifier) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.reusableId, for: indexPath) as? ChatListTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.reusableId, for: indexPath)
            }
            let chat = self.isSearchEnabled ? self.searchChatList[indexPath.item] : self.chatList[indexPath.item]
            cell.updateView(with: chat)
            return cell
        })
    }
    
    private func updateChatList() {
        chatList        = ChatUtils.shared.chatList
        searchChatList  = isSearchEnabled ? chatList.filter({($0.getSender()?.userName ?? "").lowercased().contains(searchBarText.lowercased())}) : []
        updateView(chatList: isSearchEnabled ? searchChatList : chatList)
    }
    
    private func updateView(chatList : [Chat]) {
        var snapshot = NSDiffableDataSourceSnapshot<DiffableDSSectionType,Chat>()
        snapshot.appendSections([.main])
        snapshot.appendItems(chatList)
        DispatchQueue.main.async { self.dataSource?.apply(snapshot, animatingDifferences: true) }
    }
}

extension ChatListVC : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            isSearchEnabled = false
            updateView(chatList: chatList)
            return
        }
        searchBarText   = searchText
        isSearchEnabled = true
        searchChatList  = chatList.filter({($0.getSender()?.userName ?? "").lowercased().contains(searchText.lowercased())})
        updateView(chatList: searchChatList)
    }
}

extension ChatListVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatList    = isSearchEnabled ? searchChatList : chatList
        let chat      = chatList[indexPath.item]
        showChatView(chat: chat)
    }
    
    private func showChatView(chat : Chat) {
        DispatchQueue.main.async {
            let chatVC = ChatVC(chat: chat)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}


//MARK: Notification Observers
extension ChatListVC {
    
    private func configureNotificationObserver() {
        let newMessageNotificationName  = Notification.Name(NotificationObserverName.newMessageKey)
        let newChatNotificationName     = Notification.Name(NotificationObserverName.newChatKey)
        let msgTypeingNotificationName  = Notification.Name(NotificationObserverName.messageTypingKey)
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageArrived(notification:)), name: newMessageNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newChatCreated), name: newChatNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(configureTyping(notification:)), name: msgTypeingNotificationName, object: nil)
    }
    
    @objc func newMessageArrived(notification: NSNotification) {
        guard let userInfo = notification.userInfo,let chatId = userInfo["chatId"] as? String, let message = userInfo["message"] as? Message else {
            return
        }
        if isSearchEnabled {
            updateDataForNewMessage(chatId: chatId, message: message, isSearch: true)
        }
        updateDataForNewMessage(chatId: chatId, message: message, isSearch: false)
        updateDatasForNewData()
    }
    
    private func updateDataForNewMessage(chatId: String, message : Message, isSearch : Bool) {
        var list = isSearch ? searchChatList : chatList
        guard let chat      = list.filter({$0._id == chatId}).first, let index = list.firstIndex(of: chat) else { return }
        chat.updateLastMessage(message: message)
        let indexPath       = IndexPath(item: index, section: 0)
        if let cell      = tableView.cellForRow(at: indexPath), tableView.visibleCells.contains(cell), let chatCell = cell as? ChatListTableViewCell {
            chatCell.updateViewForNewMessage(for: chat)
        } else {
            list.remove(at: index)
            list.insert(chat, at: 0)
            
            if isSearch {
                searchChatList = list
            } else {
                chatList = list
            }
        }
    }
    
    
    @objc func configureTyping(notification: NSNotification) {
        guard let userInfo = notification.userInfo,let chatId = userInfo["chat_id"] as? String, let isTyping = userInfo["is_typing"] as? Bool else {
            return
        }
        let list        = isSearchEnabled ? searchChatList : chatList
        guard let chat  = list.filter({$0._id == chatId}).first, chat.isTyping != isTyping, let index = list.firstIndex(of: chat) else { return }
        let indexPath   = IndexPath(item: index, section: 0)
        guard let cell  = tableView.cellForRow(at: indexPath), tableView.visibleCells.contains(cell), let chatCell = cell as? ChatListTableViewCell else { return }
        chat.isTyping   = isTyping
        
        chatCell.updateTyping(for: chat)
    }
    
    @objc func newChatCreated() {
        updateChatList()
    }
}
