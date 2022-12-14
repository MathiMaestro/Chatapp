//
//  LoginNetworkManager.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 19/09/22.
//

import Foundation

class LoginNetworkManager {
    
    static let shared = LoginNetworkManager()
    
    func getUserDetails(completed: @escaping (Result<UserData,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .isValidUser)), let token = PersistenceManager.token else {
            completed(.failure(.invalidToken))
            return
        }
        
        NetworkManager.shared.makeRequest(with: url, httpMethod: .get, token: token) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonData as? [String:Any], let dataJson = jsonDict["data"] as? [String:Any], let data = NCNetworkUtils.getData(from: dataJson) else {
                        completed(.failure(.invalidResponse))
                        return
                    }
                    let userData = try NCNetworkUtils.decoder.decode(UserData.self, from: data)
                    completed(.success(userData))
                }
                catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    func checkIsUserDetailAlreadyExist(userDetail: String, isEmail: Bool , completed: @escaping (Result<Bool,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: isEmail ? .checkEmailId(emailId: userDetail) : .checkUsername(userName: userDetail))) else {
            completed(.failure(.unknown))
            return
        }
        
        NetworkManager.shared.makeRequest(with: url, httpMethod: .get) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonData as? [String:Any], let data = jsonDict["data"] as? [String:Any], let isUserFound = data["user_found"] as? Bool else {
                        completed(.failure(.invalidResponse))
                        return
                    }
                    completed(.success(isUserFound))
                }
                catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    func login(with userName: String, password: String, completed: @escaping (Result<String,NCError>) -> Void) {
        
        checkIsUserDetailAlreadyExist(userDetail: userName, isEmail: false) { result in
            switch result {
            case .success(let isUserExist):
                if isUserExist {
                    self.verifyUser(with: userName, password: password) { result in
                        completed(result)
                    }
                } else {
                    completed(.failure(.invalidUser))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
        
    }
    
    func verifyUser(with userName: String, password: String, completed: @escaping (Result<String,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .login)) else {
            completed(.failure(.unknown))
            return
        }
        
        let bodyJson : [String : Any] = ["user_name":"\(userName)",
                                     "pass":"\(password)"
        ]
        
        guard let body = NCNetworkUtils.getData(from: bodyJson) else {
            completed(.failure(.unknown))
            return
        }
        
        NetworkManager.shared.makeRequest(with: url, httpMethod: .post, body: body) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonData as? [String:Any], let data = jsonDict["data"] as? [String:Any], let token = data["token"] as? String else {
                        completed(.failure(.invalidResponse))
                        return
                    }
                    completed(.success(token))
                }
                catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    func signupWith(username: String, emailId: String, password: String, completed: @escaping (Result<Bool,NCError>) -> Void) {
        checkIsUserDetailAlreadyExist(userDetail: username, isEmail: false) { [unowned self] result in
            switch result {
            case .success(let isUserExist):
                if isUserExist {
                    completed(.failure(.existedUser))
                } else {
                    self.checkIsUserDetailAlreadyExist(userDetail: emailId, isEmail: true) { result in
                        switch result {
                        case .success(let isUserExist):
                            if isUserExist {
                                completed(.failure(.existedEmail))
                            } else {
                                self.makeSignupRequestWith(username: username, emailId: emailId, password: password) { result in
                                    completed(result)
                                }
                            }
                        case .failure(let error):
                            completed(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    func makeSignupRequestWith(username: String, emailId: String, password: String, completed: @escaping (Result<Bool,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .register)) else {
            completed(.failure(.unknown))
            return
        }
        
        let bodyJson : [String : Any] = ["user_name":"\(username)",
                                     "password":"\(password)",
                                     "email_id":"\(emailId)"
        ]
        
        guard let body = NCNetworkUtils.getData(from: bodyJson) else {
            completed(.failure(.unknown))
            return
        }
        
        NetworkManager.shared.makeRequest(with: url, httpMethod: .post, body: body) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonData as? [String:Any], let data = jsonDict["data"] as? [String:Any], let isRegistered = data["created"] as? Bool else {
                        completed(.failure(.invalidResponse))
                        return
                    }
                    if isRegistered {
                        completed(.success(isRegistered))
                    } else {
                        completed(.failure(.registerFail))
                    }
                }
                catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    func deleteAccount(completed: @escaping (Result<Bool,NCError>) -> Void) {
        
        guard let url = URL(string: NCAPI.getAPI(for: .delete)), let token = PersistenceManager.token else {
            completed(.failure(.invalidToken))
            return
        }
        
        NetworkManager.shared.makeRequest(with: url, httpMethod: .delete, token: token) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonData as? [String:Any], let data = jsonDict["data"] as? [String:Any], let code = data["code"] as? String else {
                        completed(.failure(.invalidResponse))
                        return
                    }
                    if code == "300" {
                        completed(.success(true))
                    } else {
                        completed(.failure(.deleteFailure))
                    }
                }
                catch {
                    completed(.failure(.invalidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
}
