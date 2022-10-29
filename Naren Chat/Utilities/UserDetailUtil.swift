//
//  UserDetailUtil.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 21/09/22.
//

import UIKit

class UserDetailUtil {
    
    static let shared           = UserDetailUtil()
    var userData : UserData?    = nil
    let cache = NSCache<NSString,UIImage>()
    
    func removeUserData() {
        PersistenceManager.token = nil
        reset()
        ChatUtils.shared.reset()
        ContactsUtils.shared.reset()
        IOSocketManager.shared.stop()
    }
    
    func isUserLoggedinAlready() -> Bool {
        guard let _ = PersistenceManager.token else { return false }
        return true
    }
    
    func getUserDetails(completed: @escaping (NCError?) -> Void) {
        LoginNetworkManager.shared.getUserDetails { [unowned self] result in
            switch result {
            case .success(let userData):
                self.userData = userData
                completed(nil)
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    func updateProfilePic(with image: UIImage, completed: @escaping(Result<Bool,NCError>) -> Void) {
        guard let mediaImage = Media(withImage: image, forKey: "image"), let url = URL(string: NCAPI.getAPI(for: .updateUserProfile)), let token = PersistenceManager.token else { return }
        let body = createRequestBody(imageData: mediaImage.data, boundary: mediaImage.boundary, attachmentKey: mediaImage.key, fileName: mediaImage.filename, mediaType: mediaImage.mediaType)
        NetworkManager.shared.makeRequest(with: url, httpMethod: .post, body: body, token: token, isMultiPortData: true, boundary: mediaImage.boundary) { result in
            switch result {
            case .success(_):
                completed(.success(true))
            case .failure(let error):
                completed(.failure(error))
            }
        }
        
    }
    
    private func createRequestBody(imageData: Data, boundary: String, attachmentKey: String, fileName: String, mediaType: String) -> Data {
            let lineBreak = "\r\n"
            var requestBody = Data()

            requestBody.append("\(lineBreak)--\(boundary + lineBreak)" .data(using: .utf8)!)
            requestBody.append("Content-Disposition: form-data; name=\"\(attachmentKey)\"; filename=\"\(fileName)\"\(lineBreak)" .data(using: .utf8)!)
            requestBody.append("Content-Type: \(mediaType) \(lineBreak + lineBreak)" .data(using: .utf8)!) // you can change the type accordingly if you want to
            requestBody.append(imageData)
            requestBody.append("\(lineBreak)--\(boundary)--\(lineBreak)" .data(using: .utf8)!)

            return requestBody
        }
    
    
    func reset() {
        cache.removeAllObjects()
        userData = nil
    }
    
}

struct UserStatusDetail : Codable {
    let status: String
    let lastOnline: Double
    let id: String
}

struct Media {
    let key: String
    let data: Data
    let filename    = "imagefile.jpg"
    let mediaType   = "image/jpeg"
    let boundary    = "Boundary-\(UUID().uuidString)"
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        self.data = data
    }
}
