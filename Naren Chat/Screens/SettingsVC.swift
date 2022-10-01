//
//  SettingsVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 26/09/22.
//

import UIKit

class SettingsVC: NCLoadingVC {
    
    private let tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SettingsUserTableViewCell.self, forCellReuseIdentifier: SettingsUserTableViewCell.reusableId)
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsUserTableViewCell.reusableId, for: indexPath) as? SettingsUserTableViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: SettingsUserTableViewCell.reusableId, for: indexPath)
        }
        cell.delegate = self
        return cell
    }
}

extension SettingsVC : SettingsUserTableViewCellToView {
    
    func signoutTapped() {
        showLoadingView()
        PersistenceManager.token = nil
        goToLogin()
    }
    
    private func goToLogin() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
            window.rootViewController = UINavigationController(rootViewController: LoginVC())
        }
    }
}

protocol SettingsUserTableViewCellToView {
    func signoutTapped()
}

class SettingsUserTableViewCell : UITableViewCell {
    
    static let reusableId = "SettingsUserTableViewCell"
    var delegate : SettingsUserTableViewCellToView?

    private let profileImageView    = NCProfileImageView(frame: .zero)
    private let usernameLabel       = NCTitleLabel(textColor: .label, textAlignment: .left, font: .preferredFont(forTextStyle: .headline))
    private let signOutButton       = NCLogoutButton(frame: .zero)
    private let userMailLabel       = NCBodyLabel(textColor: .secondaryLabel, textAlignment: .left)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        updateData()
        confiureActions()
    }
    
    private func configureUI() {
        contentView.addSubViews(profileImageView,usernameLabel,userMailLabel,signOutButton)
        
        let padding : CGFloat               = 16
        let profileImageHeight : CGFloat    = 70
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageHeight),
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageHeight),
            
            signOutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            signOutButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            signOutButton.heightAnchor.constraint(equalToConstant: 32),
            signOutButton.widthAnchor.constraint(equalToConstant: 32),
            
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: signOutButton.leadingAnchor,constant: -10),
            
            userMailLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            userMailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            userMailLabel.trailingAnchor.constraint(equalTo: signOutButton.leadingAnchor,constant: -10),
        ])
        
        profileImageView.layer.cornerRadius     = profileImageHeight/2
        profileImageView.layer.masksToBounds    = true
        selectionStyle                          = .none
    }
    
    private func confiureActions() {
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
    }
    
    @objc func signOutTapped() {
        delegate?.signoutTapped()
    }
    
    private func updateData() {
        guard let user = UserDetailUtil.shared.userData else { return }
        usernameLabel.text = user.userName
        userMailLabel.text = user.emailId
        profileImageView.downloadImage(for: user.imgUrl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
