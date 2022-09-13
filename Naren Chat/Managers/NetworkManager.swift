//
//  NetworkManager.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 14/09/22.
//

import Foundation


class NetworkManager {
    static let shared = NetworkManager()
    
    func makeRequest(with urlRequest: URLRequest, completed: @escaping (Result<Data,NCError>) -> Void) {

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
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.inavlidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            completed(.success(data))

        }
        
        task.resume()
    }
    
    func login(with userName: String, password: String, completed: @escaping (Result<Int64,NCError>) -> Void) {
        guard let url = URL(string: NCAPI.getAPI(for: .login)) else {
            completed(.failure(.invalidLoginUrl))
            return
        }
        
        var urlRequest          = URLRequest(url: url)
        urlRequest.httpMethod   = "GET"
        
        urlRequest.setValue("user_name", forHTTPHeaderField: userName)
        urlRequest.setValue("password", forHTTPHeaderField: password)
        
        makeRequest(with: urlRequest) { result in
            print(result)
        }
    }
    
}
