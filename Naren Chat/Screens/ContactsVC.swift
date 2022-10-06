//
//  ContactsVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 26/09/22.
//

import UIKit

class ContactsVC: NCLoadingVC {

    enum DiffableDSSectionType { case main }
    
    private let tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundColor   = .systemBackground
        tableView.rowHeight         = 50
        
        tableView.register(ContactListTableViewCell.self, forCellReuseIdentifier: ContactListTableViewCell.reusableId)
        return tableView
    }()
    
    private var contactList : [UserData]    = []
    private var searchResult : [UserData]   = []
    private var isSearchEnabled : Bool      = false
    private var searchText : String         = ""
    private var isFirstTime : Bool          = true
    
    private var dataSource : UITableViewDiffableDataSource<DiffableDSSectionType,UserData>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchController()
        configureUI()
        configureDataSource()
        showLoadingView()
        getFriendsList()
        configureNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        if !isFirstTime {
            getFriendsList()
        } else {
            isFirstTime = false
        }
    }
    
    @objc func getFriendsList() {
        ContactsNetworkManager.shared.getFriendsList { [weak self] result in
            guard let self else { return }
            self.dismissLoadingView()
            switch result {
            case .success(let contactList):
                self.contactList = contactList
                if self.isSearchEnabled {
                    self.searchResult = contactList.filter({$0.userName.lowercased().contains(self.searchText.lowercased())})
                    self.updateView(on: self.searchResult)
                } else {
                    self.updateView(on: contactList)
                }
            case .failure(let error):
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
                if error == .invalidToken {
                    SessionUtil.goToLogin()
                }
            }
        }
    }
    
    private func configureNotificationObserver() {
        let newChatNotificationName     = Notification.Name(NotificationObserverName.newChatKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateContact(notification:)), name: newChatNotificationName, object: nil)
    }
    
    @objc func updateContact(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let chat = userInfo["chat"] as? Chat,
              let sender = chat.getSender(),
              contactList.contains(where: {$0.userName != sender.userName}) else
        { return }
        getFriendsList()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Contacts"
    }
    
    private func configureSearchController() {
        let searchController                                    = UISearchController()
        searchController.searchBar.placeholder                  = "Search for a user name"
        searchController.searchResultsUpdater                   = self
        searchController.obscuresBackgroundDuringPresentation   = false
        navigationItem.searchController                         = searchController
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.reusableId, for: indexPath) as? ContactListTableViewCell, let self else {
                return tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.reusableId, for: indexPath)
            }
            let userData = self.isSearchEnabled ? self.searchResult[indexPath.item] : self.contactList[indexPath.item]
            cell.updateView(with: userData)
            return cell
        })
    }
    
    private func updateView(on contactList : [UserData]) {
        var snapShot = NSDiffableDataSourceSnapshot<DiffableDSSectionType, UserData>()
        snapShot.appendSections([.main])
        snapShot.appendItems(contactList)
        DispatchQueue.main.async { self.dataSource?.apply(snapShot, animatingDifferences: true) }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.frame     = view.bounds
    }
}

extension ContactsVC : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            isSearchEnabled = false
            updateView(on: contactList)
            return
        }
        isSearchEnabled = true
        self.searchText = searchText
        searchResult = contactList.filter({$0.userName.lowercased().contains(searchText.lowercased())})
        updateView(on: searchResult)
    }
}
