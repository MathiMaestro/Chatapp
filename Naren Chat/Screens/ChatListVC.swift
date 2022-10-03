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
    private var searchBarText: String      = ""
    
    private var editBarButtonItem: UIBarButtonItem?
    private var doneBarButtonItem: UIBarButtonItem?
    private var deleteBarButtonItem: UIBarButtonItem?
    
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
    
    private func configureNotificationObserver() {
        let newMessageNotificationName  = Notification.Name(NotificationObserverName.newMessageKey)
        let newChatNotificationName     = Notification.Name(NotificationObserverName.newChatKey)
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageArrived), name: newMessageNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newChatCreated), name: newChatNotificationName, object: nil)
    }
    
    @objc func newMessageArrived() {
        
    }
    
    @objc func newChatCreated() {
        chatList        = ChatUtils.shared.chatList
        searchChatList  = chatList.filter({($0.getSender()?.userName ?? "").lowercased().contains(searchBarText.lowercased())})
        updateView(chatList: isSearchEnabled ? searchChatList : chatList)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        editBarButtonItem                   = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editOptionTapped))
        doneBarButtonItem                   = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneOptionTapped))
        deleteBarButtonItem                 = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped))
        navigationItem.leftBarButtonItem    = editBarButtonItem
        title = "Chats"
    }
    
    @objc func editOptionTapped() {
        tableView.setEditing(true, animated: true)
        navigationItem.leftBarButtonItem    = doneBarButtonItem
        navigationItem.rightBarButtonItem   = deleteBarButtonItem
    }
    
    @objc func doneOptionTapped() {
        tableView.setEditing(false, animated: true)
        navigationItem.leftBarButtonItem = editBarButtonItem
    }
    
    @objc func deleteButtonTapped() {
        let indexPaths = tableView.indexPathsForSelectedRows
        tableView.setEditing(false, animated: true)
        navigationItem.leftBarButtonItem    = editBarButtonItem
        navigationItem.rightBarButtonItem   = nil
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
    
    @objc func getChatList() {
        showLoadingView()
        ChatUtils.shared.getChatList(listCount: listCount) { [weak self] result in
            guard let self else { return }
            self.dismissLoadingView()
            switch result {
            case .success(let chatListData):
                self.chatList           = chatListData.chats
                self.isDataAvailable    = chatListData.hasMore
                self.updateView(chatList: self.chatList)
            case .failure(let error):
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
                if error == .invalidToken {
                    SessionUtil.goToLogin()
                }
            }
        }
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: self.tableView, cellProvider: { [weak self] (tableView, indexPath, itemIdentifier) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.reusableId, for: indexPath) as? ChatListTableViewCell, let self else {
                return tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.reusableId, for: indexPath)
            }
            let chat = self.isSearchEnabled ? self.searchChatList[indexPath.item] : self.chatList[indexPath.item]
            cell.updateView(with: chat)
            return cell
        })
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
        let chatId      = chatList[indexPath.item]._id
        showChatView(chatId: chatId)
    }
    
    private func showChatView(chatId : String) {
        DispatchQueue.main.async {
            let chatVC = ChatVC(chatId: chatId)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}
