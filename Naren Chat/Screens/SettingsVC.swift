//
//  SettingsVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 26/09/22.
//

import UIKit

enum SettingsOptions: String {
    case accountDelete  = "Delete Account"
    case notifications  = "Notifications"
    case privacy        = "Privacy"
}

class SettingsVC: NCLoadingVC {
    
    private let settings : [Int:SettingsOptions] = [0:.notifications,1:.privacy,2:.accountDelete]
    
    private let tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(SettingsUserTableViewCell.self, forCellReuseIdentifier: SettingsUserTableViewCell.reusableId)
        tableView.register(SettingsOptionTableViewCell.self, forCellReuseIdentifier: SettingsOptionTableViewCell.reusableId)
        
        tableView.backgroundColor = .systemGroupedBackground
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Settings"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        
        tableView.frame         = view.bounds
        tableView.delegate      = self
        tableView.dataSource    = self
        
        tableView.reloadData()
    }
    
    deinit {
        print("SettingsVC deinitialized")
    }

}

extension SettingsVC : UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : settings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 100 : 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsUserTableViewCell.reusableId, for: indexPath) as? SettingsUserTableViewCell else {
                return tableView.dequeueReusableCell(withIdentifier: SettingsUserTableViewCell.reusableId, for: indexPath)
            }
            cell.setDelegates(to: self)
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsOptionTableViewCell.reusableId, for: indexPath) as? SettingsOptionTableViewCell,let type  = settings[indexPath.item] else {
                return  tableView.dequeueReusableCell(withIdentifier: SettingsOptionTableViewCell.reusableId, for: indexPath)
            }
            cell.updateData(for: type)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0, let type = settings[indexPath.item] else { return }
        switch type {
            case .accountDelete:
            DispatchQueue.main.async { self.presentDeleteAlertVC() }
            default:
                break
        }
    }
}

// MARK: Account deletion methods
extension SettingsVC {
    
    private func presentDeleteAlertVC() {
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            self.showLoadingView()
            self.deleteAccount()
        }
        let cancelAction    = UIAlertAction(title: "Cancel", style: .cancel)
        let alertVC         = UIAlertController(title: "Delete Account", message: "Are you sure. Do you want to delete this account?", preferredStyle: .alert)
        alertVC.addAction(cancelAction)
        alertVC.addAction(deleteAction)
        present(alertVC, animated: true)
    }
    
    private func deleteAccount() {
        LoginNetworkManager.shared.deleteAccount { [unowned self] result in
            self.dismissLoadingView()
            switch result {
            case .success(let success):
                if success {
                    UserDetailUtil.shared.removeUserData()
                    SessionUtil.goToLogin(title: "We miss you", message: "Your account deleted successfully")
                } else {
                    self.presentNCAlertViewInMainThread(title: "Oops..", message: "Sorry. Unable to delete your account", buttonTitle: "Ok")
                }
            case .failure(let error):
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
}

extension SettingsVC : SettingsUserTableViewCellToView {
    
    func profileImageUpdated(with error: NCError?) {
        if let _ = error {
            presentNCAlertViewInMainThread(title: "Sorry..", message: "Something went wrong! Unable to update the profile pic", buttonTitle: "Ok")
        } else {
            presentNCAlertViewInMainThread(title: "Hurray..", message: "Profile pic updated successfully", buttonTitle: "Ok")
        }
    }
    
    func signoutTapped() {
        UserDetailUtil.shared.removeUserData()
        SessionUtil.goToLogin()
    }
}
