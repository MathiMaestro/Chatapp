//
//  SettingsUserTableViewCell.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 02/10/22.
//

import UIKit

protocol SettingsUserTableViewCellToView : AnyObject {
    func signoutTapped()
    func profileImageUpdated(with error: NCError?)
    func showLoadingView()
    func dismissLoadingView()
}

class SettingsUserTableViewCell : UITableViewCell {
    
    static let reusableId = "SettingsUserTableViewCell"
    weak var delegate: SettingsUserTableViewCellToView?
    weak var view: UIView?

    private let profileImageView    = NCProfileImageView(frame: .zero)
    private let usernameLabel       = NCTitleLabel(textColor: .label, textAlignment: .left, font: .preferredFont(forTextStyle: .headline))
    private let signOutButton       = NCLogoutButton(frame: .zero)
    private let userMailLabel       = NCBodyLabel(textColor: .secondaryLabel, textAlignment: .left)
    
    var imagePicker: ImagePickerController?
    
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
        
        updateProfileImage()
        imagePicker = ImagePickerController(delegate: self)
    }
    
    private func confiureActions() {
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tap)
        profileImageView.isUserInteractionEnabled = true
    }
    
    private func updateProfileImage() {
        guard let profileImgurl = UserDetailUtil.shared.userData?.imgUrl else { return }
        profileImageView.downloadImage(for: profileImgurl)
    }
    
    @objc func profileImageTapped() {
        DispatchQueue.main.async {
            self.imagePicker?.present(from: self.view)
        }
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
    
    func setDelegates(to VC: SettingsVC?) {
        delegate                               = VC
        view                                   = VC?.view
        imagePicker?.setPresentationViewController(VC: VC)
    }
    
    deinit {
        print("SettingsUserTableViewCell deinitialized")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingsUserTableViewCell: ImagePickerControllerDelegate {
    
    func didSelect(image: UIImage?) {
        guard let image else { return }
        delegate?.showLoadingView()
        UserDetailUtil.shared.updateProfilePic(with: image) { [unowned self] result in
            self.delegate?.dismissLoadingView()
            switch result {
            case .success(_):
                self.delegate?.profileImageUpdated(with: nil)
                self.setProfileImage(with: image)
            case .failure(_):
                self.delegate?.profileImageUpdated(with: .profilePicUpdate)
            }
        }
    }
    
    private func setProfileImage(with image: UIImage) {
        DispatchQueue.main.async {
            self.profileImageView.image = image
        }
    }
}
