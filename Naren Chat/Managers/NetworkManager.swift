//
//  NetworkManager.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 14/09/22.
//

import Foundation


class NetworkManager {
    static let shared = NetworkManager()
    
    func makeRequest(with url: URL, httpMethod: HttpMethod, body: Data? = nil, token: String? = nil, completed: @escaping (Result<Data,NCError>) -> Void) {
        let urlRequest = NCNetworkUtils.createUrlRequest(for: url, httpMethod: httpMethod, token: token, body: body)
        
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
                completed(.failure(.invalidResponse))
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
            case 400:
                completed(.failure(.invalidToken))
            default:
                completed(.failure(.unknown))
            }

        }
        
        task.resume()
    }
    
}
