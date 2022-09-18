//
//  LoginViewController.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 10/09/22.
//

import UIKit

class LoginViewController: UIViewController {

    private let loginView   = LoginView(isSignUp: false)
    private let signupView  = LoginView(isSignUp: true)
    var isLoginEnabled      = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
    }
    
    private func configureUI() {
        view.addSubViews(loginView,signupView)

        loginView.pinToEdges(of: view)
        signupView.pinToEdges(of: view)
        
        loginView.delegate  = self
        signupView.delegate = self
        
        signupView.isHidden = true
    }
}

extension LoginViewController : LoginViewToVC {
    
    func actionButtonTapped() {
        isLoginEnabled ? login() : signup()
    }
    
    private func login() {
        let username = loginView.getUsernameText() ?? ""
        let password = loginView.getPasswordText() ?? ""
        NetworkManager.shared.login(with: username, password: password) { result in
            switch result {
            case .success(let token):
                print(token)
            case .failure(let error):
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    private func signup() {
        let username = signupView.getUsernameText() ?? ""
        let password = signupView.getPasswordText() ?? ""
        let emailId = signupView.getEmailIdText() ?? ""
        NetworkManager.shared.signupWith(username: username, emailId: emailId, password: password) { result in
            switch result {
            case .success(_):
                self.presentNCAlertViewInMainThread(title: "Hurray!", message: NCError.registerSuccess.rawValue, buttonTitle: "Ok")
            case .failure(let error):
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    func actionLabelTapped() {
        isLoginEnabled      = !isLoginEnabled
        signupView.isHidden = !signupView.isHidden
        loginView.isHidden  = !loginView.isHidden
    }
}

