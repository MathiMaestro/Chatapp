//
//  LoginVC.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 10/09/22.
//

import UIKit

class LoginVC: NCLoadingVC {

    private let loginView   = LoginView(isSignUp: false)
    private let signupView  = LoginView(isSignUp: true)
    var isLoginEnabled      = true
    
    init(title : String? = nil, message: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        if title != nil || message != nil {
            self.presentNCAlertViewInMainThread(title: title ?? "Oops..", message: message ?? "Something went wrong", buttonTitle: "Ok")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        createDismissKeyboardTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    private func configureUI() {
        view.addSubViews(loginView,signupView)

        loginView.pinToEdges(of: view)
        signupView.pinToEdges(of: view)
        
        loginView.delegate  = self
        signupView.delegate = self
        
        signupView.isHidden = true
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    deinit {
        print("LoginVC deinitialized")
    }
}

extension LoginVC {
    
    private func login() {
        let username = loginView.getUsernameText() ?? ""
        let password = loginView.getPasswordText() ?? ""
        LoginNetworkManager.shared.login(with: username, password: password) { [unowned self] result in
            switch result {
            case .success(let token):
                PersistenceManager.token = token
                self.presentLauncherVC()
            case .failure(let error):
                self.dismissLoadingView()
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    private func signup() {
        let username = signupView.getUsernameText() ?? ""
        let password = signupView.getPasswordText() ?? ""
        let emailId = signupView.getEmailIdText() ?? ""
        LoginNetworkManager.shared.signupWith(username: username, emailId: emailId, password: password) { [unowned self] result in
            self.dismissLoadingView()
            switch result {
            case .success(_):
                self.presentNCAlertViewInMainThread(title: "Hurray!", message: NCError.registerSuccess.rawValue, buttonTitle: "Ok")
            case .failure(let error):
                self.presentNCAlertViewInMainThread(title: "Oops..", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    private func presentLauncherVC() {
        DispatchQueue.main.async {
            self.dismissLoadingView()
            self.navigationController?.pushViewController(LauncherVC(), animated: true)
        }
    }
}

extension LoginVC : LoginViewToVC {
    
    func actionButtonTapped() {
        showLoadingView()
        isLoginEnabled ? login() : signup()
    }
    
    func actionLabelTapped() {
        isLoginEnabled      = !isLoginEnabled
        signupView.isHidden = !signupView.isHidden
        loginView.isHidden  = !loginView.isHidden
        loginView.resetValues()
        signupView.resetValues()
    }
}

