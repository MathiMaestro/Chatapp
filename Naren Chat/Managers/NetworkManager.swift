//
//  NetworkManager.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 14/09/22.
//

import Foundation


class NetworkManager {
    static let shared = NetworkManager()
    
    func makeRequest(with urlRequest: URLRequest ,body: Data? = nil, completed: @escaping (Result<Data,NCError>) -> Void) {
        var urlRequest = urlRequest
        
        if let body {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                let nsError = error as NSError
                
                switch nsError.code {
                    case NSURLErrorNotConnectedToInternet, NSURLErrorInternationalRoamingOff, NSURLErrorDataNotAllowed:
                        completed(.failure(.networkConnection))
                    default:
                        completed(.failure(.unknown))
                }
            }
            
            guard let response = response as? HTTPURLResponse else {
                completed(.failure(.inavlidResponse))
                return
            }
            
            switch response.statusCode {
            case 200:
                guard let data = data else {
                    completed(.failure(.invalidData))
                    return
                }
                
                completed(.success(data))
            case 500:
                completed(.failure(.invalidPassowrd))
            default:
                break
            }

        }
        
        task.resume()
    }
    
    private func getHttpBody(from bodyJson: [String : Any]) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: bodyJson)
        } catch {
            return nil
        }
    }
    
    func checkIsUserDetailAlreadyExist(userDetail: String, isEmail: Bool , completed: @escaping (Result<Bool,NCError>) -> Void) {
        guard let url = URL(string: (isEmail ? NCAPI.getAPI(for: .checkEmailId) : NCAPI.getAPI(for: .checkUsername)) + "\(userDetail)") else {
            completed(.failure(.unknown))
            return
        }
        let urlRequest = createUrlRequest(for: url, httpMethod: "GET")
        makeRequest(with: urlRequest) { result in
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
        
        let urlRequest = createUrlRequest(for: url, httpMethod: "POST")
        
        let bodyJson : [String : Any] = ["user_name":"\(userName)",
                                     "pass":"\(password)"
        ]
        
        guard let body = getHttpBody(from: bodyJson) else {
            completed(.failure(.unknown))
            return
        }
        
        makeRequest(with: urlRequest, body: body) { result in
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
        
        let urlRequest = createUrlRequest(for: url, httpMethod: "POST")
        
        let bodyJson : [String : Any] = ["user_name":"\(username)",
                                     "password":"\(password)",
                                     "email_id":"\(emailId)"
        ]
        
        guard let body = getHttpBody(from: bodyJson) else {
            completed(.failure(.unknown))
            return
        }
        
        makeRequest(with: urlRequest, body: body) { result in
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
    
    private func createUrlRequest(for url: URL, httpMethod: String) -> URLRequest {
        var urlRequest          = URLRequest(url: url)
        urlRequest.httpMethod   = httpMethod
        return urlRequest
    }
    
}
