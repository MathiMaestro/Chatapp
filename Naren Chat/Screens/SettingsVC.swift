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
            cell.delegate = self
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
                print("hello")
            default:
                break
        }
    }
}

extension SettingsVC : SettingsUserTableViewCellToView {
    
    func signoutTapped() {
        showLoadingView()
        UserDetailUtil.shared.removeUserData()
        SessionUtil.goToLogin()
    }
}