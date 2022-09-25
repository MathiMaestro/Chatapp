//
//  LoginNetworkManager.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 19/09/22.
//

import Foundation

class LoginNetworkManager {
    
    static let shared = LoginNetworkManager()
    var decoder : JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func getUserDetails(completed: @escaping (Result<UserData?,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .isValidUser)), let token = PersistenceManager.token else {
            completed(.failure(.invalidToken))
            return
        }
        var urlRequest = NCNetworkUtils.createUrlRequest(for: url, httpMethod: "GET")
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        NetworkManager.shared.makeRequest(with: urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonData as? [String:Any], let dataJson = jsonDict["data"] as? [String:Any], let data = NCNetworkUtils.getHttpBody(from: dataJson) else {
                        completed(.failure(.invalidToken))
                        return
                    }
                    let userData = try self.decoder.decode(UserData.self, from: data)
                    completed(.success(userData))
                }
                catch {
                    completed(.failure(.invalidToken))
                }
            case .failure(_):
                completed(.failure(.invalidToken))
            }
        }
    }
    
    func checkIsUserDetailAlreadyExist(userDetail: String, isEmail: Bool , completed: @escaping (Result<Bool,NCError>) -> Void) {
        guard let url = URL(string: (isEmail ? NCAPI.getAPI(for: .checkEmailId) : NCAPI.getAPI(for: .checkUsername)) + "\(userDetail)") else {
            completed(.failure(.unknown))
            return
        }
        let urlRequest = NCNetworkUtils.createUrlRequest(for: url, httpMethod: "GET")
        NetworkManager.shared.makeRequest(with: urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonData as? [String:Any], let data = jsonDict["data"] as? [String:Any], let isUserFound = data["user_found"] as? Bool else {
                        completed(.failure(.inavlidResponse))
                        return
                    }
                    completed(.success(isUserFound))
                }
                catch {
                    completed(.failure(.inavlidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    func login(with userName: String, password: String, completed: @escaping (Result<String?,NCError>) -> Void) {
        
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
    
    func verifyUser(with userName: String, password: String, completed: @escaping (Result<String?,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .login)) else {
            completed(.failure(.unknown))
            return
        }
        
        let urlRequest = NCNetworkUtils.createUrlRequest(for: url, httpMethod: "POST")
        
        let bodyJson : [String : Any] = ["user_name":"\(userName)",
                                     "pass":"\(password)"
        ]
        
        guard let body = NCNetworkUtils.getHttpBody(from: bodyJson) else {
            completed(.failure(.unknown))
            return
        }
        
        NetworkManager.shared.makeRequest(with: urlRequest, body: body) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonData as? [String:Any], let data = jsonDict["data"] as? [String:Any], let token = data["token"] as? String else {
                        completed(.failure(.inavlidResponse))
                        return
                    }
                    completed(.success(token))
                }
                catch {
                    completed(.failure(.inavlidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    func signupWith(username: String, emailId: String, password: String, completed: @escaping (Result<Bool,NCError>) -> Void) {
        checkIsUserDetailAlreadyExist(userDetail: username, isEmail: false) { result in
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
        
        let urlRequest = NCNetworkUtils.createUrlRequest(for: url, httpMethod: "POST")
        
        let bodyJson : [String : Any] = ["user_name":"\(username)",
                                     "password":"\(password)",
                                     "email_id":"\(emailId)"
        ]
        
        guard let body = NCNetworkUtils.getHttpBody(from: bodyJson) else {
            completed(.failure(.unknown))
            return
        }
        
        NetworkManager.shared.makeRequest(with: urlRequest, body: body) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let jsonDict = jsonData as? [String:Any], let data = jsonDict["data"] as? [String:Any], let isRegistered = data["created"] as? Bool else {
                        completed(.failure(.inavlidResponse))
                        return
                    }
                    if isRegistered {
                        completed(.success(isRegistered))
                    } else {
                        completed(.failure(.registerFail))
                    }
                }
                catch {
                    completed(.failure(.inavlidResponse))
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
}
