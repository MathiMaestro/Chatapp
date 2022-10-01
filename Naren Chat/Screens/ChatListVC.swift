//
//  ChatListVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 18/09/22.
//

import UIKit

class ChatListVC: NCLoadingVC {

    enum DiffableDSSectionType { case main }
    
    private var socketManager : IOSocketManager?
    
    private var listCount : Int         = 100
    private var isDataAvailable : Bool  = true
    
    private let tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundColor = .systemBackground
        tableView.register(ChatListTableViewCell.self, forCellReuseIdentifier: ChatListTableViewCell.reusableId)
        
        return tableView
    }()
    
    private var dataSource : UITableViewDiffableDataSource<DiffableDSSectionType,Chat>?
    
    private var chatList : [Chat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureDataSource()
        getChatList()
    }
    
    private func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: nil)
        title = "Chats"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.delegate = self
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
                self.updateView()
            case .failure(let error):
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: self.tableView, cellProvider: { (tableView, indexPath, itemIdentifier) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.reusableId, for: indexPath) as? ChatListTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.reusableId, for: indexPath)
            }
            let chat = self.chatList[indexPath.item]
            cell.updateView(with: chat)
            return cell
        })
    }
    
    private func updateView() {
        var snapshot = NSDiffableDataSourceSnapshot<DiffableDSSectionType,Chat>()
        snapshot.appendSections([.main])
        snapshot.appendItems(chatList)
        DispatchQueue.main.async { self.dataSource?.apply(snapshot, animatingDifferences: true) }
    }
}

extension ChatListVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
}
