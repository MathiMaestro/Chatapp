//
//  LauncherVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 21/09/22.
//

import UIKit

class LauncherVC: NCLoadingVC {
    
    let loadingContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let userProfileBackground : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image         = #imageLiteral(resourceName: "loading_circle")
        imageView.contentMode   = .scaleAspectFill
        return imageView
    }()
    
    let userProfileAnimation : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode   = .scaleAspectFill
        return imageView
    }()
    
    let initializingLabel   = NCBodyLabel(textColor: .secondaryLabel, textAlignment: .center, title: "Intializing . . .")
    let launcherMessage     = NCBodyLabel(textColor: .secondaryLabel, textAlignment: .center, title: "Hang on a sec. We're making everything ready for you")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupView()
        getUserDetails()
    }
    
    private func setupView()
    {
        view.addSubview(loadingContainer)
        loadingContainer.addSubViews(userProfileBackground,userProfileAnimation,initializingLabel,launcherMessage)
        
        NSLayoutConstraint.activate([
            loadingContainer.widthAnchor.constraint(equalToConstant: 295.0),
            loadingContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingContainer.heightAnchor.constraint(equalToConstant: 240),
            
            userProfileBackground.widthAnchor.constraint(equalToConstant: 123),
            userProfileBackground.heightAnchor.constraint(equalToConstant: 123),
            userProfileBackground.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            userProfileBackground.topAnchor.constraint(equalTo: loadingContainer.topAnchor),
            
            userProfileAnimation.widthAnchor.constraint(equalToConstant: 123),
            userProfileAnimation.heightAnchor.constraint(equalToConstant: 123),
            userProfileAnimation.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            userProfileAnimation.topAnchor.constraint(equalTo: loadingContainer.topAnchor, constant: 1),
            
            initializingLabel.leadingAnchor.constraint(equalTo: loadingContainer.leadingAnchor, constant: 10),
            initializingLabel.trailingAnchor.constraint(equalTo: loadingContainer.trailingAnchor, constant: -10),
            initializingLabel.topAnchor.constraint(equalTo: userProfileBackground.bottomAnchor, constant: 20.0),
            initializingLabel.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor, constant: 0),
            
            launcherMessage.leadingAnchor.constraint(equalTo: loadingContainer.leadingAnchor, constant: 10),
            launcherMessage.trailingAnchor.constraint(equalTo: loadingContainer.trailingAnchor, constant: -10),
            launcherMessage.topAnchor.constraint(equalTo: initializingLabel.bottomAnchor, constant: 10.0),
            launcherMessage.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor, constant: 0)
        ])
        
        imageUpdate()
    }
    
    private func imageUpdate() {
        let paddingInset:CGFloat    = -15.0
        let image                   = UIImage(systemName: "person.fill")
        userProfileAnimation.image  = image?.withAlignmentRectInsets(UIEdgeInsets(top: paddingInset, left: paddingInset, bottom: paddingInset, right: paddingInset))
        
        rotate360Degrees(targetView: userProfileBackground)
    }
    
    private func rotate360Degrees(targetView:UIView) {
        let rotateAnimation                     = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue               = 0.0
        rotateAnimation.toValue                 = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion   = false
        rotateAnimation.duration                = 1
        rotateAnimation.repeatCount             = Float.infinity
        
        targetView.layer.add(rotateAnimation, forKey: nil)
    }
    
    private func getUserDetails() {
        UserDetailUtil.shared.getUserDetails { error in
            if let error {
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
                UserDetailUtil.shared.removeUserData()
                self.goToLoginPage()
            } else {
                self.showChatListVC()
            }
        }
    }
    
    private func showChatListVC() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
            window.rootViewController = UINavigationController(rootViewController: NCTabBarController())
        }
    }
    
    private func goToLoginPage() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
            window.rootViewController = UINavigationController(rootViewController: LoginVC())
        }
    }
}
