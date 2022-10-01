//
//  NCProfileImageView.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 01/10/22.
//

import UIKit

class NCProfileImageView: UIImageView {
    
    private let cache = NSCache<NSString,UIImage>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureProperties()
    }
    
    private func configureProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleToFill
        image       = UIImage(systemName: "person.circle.fill")
        tintColor   = .systemGray2
    }
    
    func downloadImage(for urlString: String) {
        let cacheKey = NSString(string: urlString)
        if let profileImage = cache.object(forKey: cacheKey) {
            self.image = profileImage
        }
        
        guard let url   = URL(string: urlString) else { return }
        let urlRequest  = NCNetworkUtils.createUrlRequest(for: url, httpMethod: .get)
        
        NetworkManager.shared.makeRequest(with: urlRequest) { result in
            switch result {
            case .success(let data):
                if let profileImage = UIImage(data: data) {
                    self.cache.setObject(profileImage, forKey: cacheKey)
                    DispatchQueue.main.async { self.image = profileImage }
                }
            case .failure(_):
                return
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
