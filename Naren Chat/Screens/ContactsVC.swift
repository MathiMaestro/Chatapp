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
    
    private var contactList : [UserData] = []
    
    private var dataSource : UITableViewDiffableDataSource<DiffableDSSectionType,UserData>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchController()
        configureUI()
        configureDataSource()
        getFriendsList()
    }
    
    private func getFriendsList() {
        showLoadingView()
        ContactsNetworkManager.shared.getFriendsList { [weak self] result in
            guard let self else { return }
            self.dismissLoadingView()
            switch result {
            case .success(let contactList):
                self.contactList = contactList
                self.updateView(on: contactList)
            case .failure(let error):
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
                if error == .invalidToken {
                    SessionUtil.goToLogin()
                }
            }
        }
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Contacts"
    }
    
    private func configureSearchController() {
        let searchController                                    = UISearchController()
        searchController.searchBar.placeholder                  = "enter a user name"
        searchController.searchResultsUpdater                   = self
        searchController.obscuresBackgroundDuringPresentation   = false
        navigationItem.searchController                         = searchController
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.reusableId, for: indexPath) as? ContactListTableViewCell, let self else {
                return tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.reusableId, for: indexPath)
            }
            let userData = self.contactList[indexPath.item]
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
            updateView(on: contactList)
            return
        }
        let searchResult = contactList.filter({$0.userName.lowercased().contains(searchText.lowercased())})
        updateView(on: searchResult)
    }
}
