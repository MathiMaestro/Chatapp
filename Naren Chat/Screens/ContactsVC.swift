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
    
//    private var contactList : [UserData]    = []
    private var searchResult : [UserData]   = []
    private var isSearchEnabled : Bool      = false
    private var searchText : String         = ""
    
    private var dataSource : UITableViewDiffableDataSource<DiffableDSSectionType,UserData>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchController()
        configureUI()
        configureDataSource()
        configureNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles  = true
        tabBarController?.tabBar.isHidden                       = false
    }
    
    private func configureNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateContact(notification:)), name: NotificationObserverName.newChatKey, object: nil)
    }
    
    @objc func updateContact(notification: NSNotification) {
        updateView(on: ContactsUtils.shared.friendList)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("ContactsVC deinitalized")
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
        dataSource = .init(tableView: tableView, cellProvider: { [unowned self] tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.reusableId, for: indexPath) as? ContactListTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.reusableId, for: indexPath)
            }
            let userData = self.isSearchEnabled ? self.searchResult[indexPath.item] : ContactsUtils.shared.friendList[indexPath.item]
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
        tableView.delegate  = self
        updateView(on: ContactsUtils.shared.friendList)
    }
}

extension ContactsVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = isSearchEnabled ? searchResult[indexPath.item] : ContactsUtils.shared.friendList[indexPath.item]
        guard let chat = ChatUtils.shared.getChat(for: contact) else { return }
        showChatView(chat: chat)
    }
    
    private func showChatView(chat : Chat) {
        DispatchQueue.main.async {
            let chatVC = ChatVC(chat: chat)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}

extension ContactsVC : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            isSearchEnabled = false
            updateView(on: ContactsUtils.shared.friendList)
            return
        }
        isSearchEnabled = true
        self.searchText = searchText
        searchResult = ContactsUtils.shared.friendList.filter({$0.userName.lowercased().contains(searchText.lowercased())})
        updateView(on: searchResult)
    }
}
