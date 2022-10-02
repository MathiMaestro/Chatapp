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
    
    private let tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundColor = .systemBackground
        tableView.register(ChatListTableViewCell.self, forCellReuseIdentifier: ChatListTableViewCell.reusableId)
        tableView.rowHeight = 66
        return tableView
    }()
    
    private var dataSource : UITableViewDiffableDataSource<DiffableDSSectionType,Chat>?
    
    private var chatList : [Chat]   = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchController()
        configureUI()
        configureDataSource()
        getChatList()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: nil)
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
        view.addSubview(tableView)
    }
    
    private func getChatList() {
        showLoadingView()
        ChatListNetworkManager.shared.getChatList(listCount: listCount) { [weak self] result in
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
            let chat = self.chatList[indexPath.item]
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
            updateView(chatList: chatList)
            return
        }
        let searchList = chatList.filter({($0.getSender()?.userName ?? "").lowercased().contains(searchText.lowercased())})
        updateView(chatList: searchList)
    }
}
