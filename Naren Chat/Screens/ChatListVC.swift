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
            updateDatasForNewData()
        }
        isFirstTime = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("ChatListVC deinitialized")
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
        view.addSubview(tableView)
        tableView.frame         = view.bounds
        tableView.delegate      = self
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
                self.isDataAvailable    = chatListData.hasMore
                self.updateDatasForNewData()
            case .failure(let error):
                if error == .invalidToken {
                    SessionUtil.goToLogin(title: "Oops..", message: error.rawValue)
                } else {
                    self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
                }
            }
        }
    }
    
    private func updateDatasForNewData() {
        chatList = ChatUtils.shared.chatList
        if isSearchEnabled {
            searchChatList = chatList.filter({($0.getSender()?.userName ?? "").lowercased().contains(searchBarText.lowercased())})
            updateView(chatList: searchChatList)
        } else {
            updateView(chatList: chatList)
        }
    }
    
    private func updateViewWithNewData() {
        if isSearchEnabled {
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
    
    @objc func updateChatList() {
        chatList        = ChatUtils.shared.chatList
        searchChatList  = isSearchEnabled ? chatList.filter({($0.getSender()?.userName ?? "").lowercased().contains(searchBarText.lowercased())}) : []
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
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageArrived), name: NotificationObserverName.newMessageKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(configureTyping(notification:)), name: NotificationObserverName.messageTypingKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(configureRead(notification:)), name: NotificationObserverName.sentMessageReadKey, object: nil)
    }
    
    @objc func newMessageArrived(notification: NSNotification) {
        guard let userInfo = notification.userInfo,let chatId = userInfo["chatId"] as? String, let message = userInfo["message"] as? Message else {
            return
        }
        if isSearchEnabled {
            updateDataForNewMessage(chatId: chatId, message: message, isSearch: true)
        } else {
            updateDataForNewMessage(chatId: chatId, message: message, isSearch: false)
        }
    }
    
    private func updateDataForNewMessage(chatId: String, message : Message, isSearch : Bool) {
        let list = isSearch ? searchChatList : chatList
        guard var chat = list.filter({$0._id == chatId}).first, let index = list.firstIndex(of: chat) else {
            updateViewWithNewData()
            return
        }
        let indexPath       = IndexPath(item: index, section: 0)
        if index == 0, let cell = tableView.cellForRow(at: indexPath), tableView.visibleCells.contains(cell), let chatCell = cell as? ChatListTableViewCell {
            chat.updateLastMessage(message: message)
            chatCell.updateViewForNewMessage(for: chat)
            updateChatList()
        } else {
            updateChatList()
            updateViewWithNewData()
        }
    }
    
    @objc func configureRead(notification: NSNotification) {
        guard let userInfo = notification.userInfo,let chatId = userInfo["chat_id"] as? String else {
            return
        }
        updateChatList()
        let list        = isSearchEnabled ? searchChatList : chatList
        guard let chat  = list.filter({$0._id == chatId}).first, let index = list.firstIndex(of: chat) else { return }
        let indexPath   = IndexPath(item: index, section: 0)
        guard let cell  = tableView.cellForRow(at: indexPath), tableView.visibleCells.contains(cell), let chatCell = cell as? ChatListTableViewCell else { return }
        chatCell.updateSentMessageRead(for: chat)
    }
    
    @objc func configureTyping(notification: NSNotification) {
        guard let userInfo = notification.userInfo,let chatId = userInfo["chat_id"] as? String else {
            return
        }
        updateChatList()
        let list        = isSearchEnabled ? searchChatList : chatList
        guard let chat  = list.filter({$0._id == chatId}).first, let index = list.firstIndex(of: chat) else { return }
        let indexPath   = IndexPath(item: index, section: 0)
        guard let cell  = tableView.cellForRow(at: indexPath), tableView.visibleCells.contains(cell), let chatCell = cell as? ChatListTableViewCell else { return }
        chatCell.updateTyping(for: chat)
    }
    
}
