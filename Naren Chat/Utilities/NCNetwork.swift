//
//  NCNetwork.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 19/09/22.
//

import Foundation

class NCNetworkUtils {
    
    static func createUrlRequest(for url: URL, httpMethod: String) -> URLRequest {
        var urlRequest          = URLRequest(url: url)
        urlRequest.httpMethod   = httpMethod
        return urlRequest
    }
    
    static func getHttpBody(from bodyJson: [String : Any]) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: bodyJson)
        } catch {
            return nil
        }
    }
}
