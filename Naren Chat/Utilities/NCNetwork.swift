//
//  NCNetwork.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 19/09/22.
//

import Foundation


enum HttpMethod : String {
    case get    = "GET"
    case post   = "POST"
}

enum NCNetworkUtils {
    
    static let decoder : JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy     = .convertFromSnakeCase
        return decoder
    }()
    
    static func createUrlRequest(for url: URL, httpMethod: HttpMethod) -> URLRequest {
        var urlRequest          = URLRequest(url: url)
        urlRequest.httpMethod   = httpMethod.rawValue
        return urlRequest
    }
    
    static func getData(from bodyJson: [String : Any]) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: bodyJson)
        } catch {
            return nil
        }
    }
}
