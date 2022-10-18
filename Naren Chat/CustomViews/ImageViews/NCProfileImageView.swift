//
//  NCProfileImageView.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 01/10/22.
//

import UIKit

class NCProfileImageView: UIImageView {
    
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
    
    func resetImage() {
        image = UIImage(systemName: "person.circle.fill")
    }
    
    func downloadImage(for urlString: String) {
        let cacheKey = NSString(string: urlString)
        if let profileImage = UserDetailUtil.shared.cache.object(forKey: cacheKey) {
            self.image = profileImage
        }
        
        guard let url = URL(string: urlString) else { return }
        
        NetworkManager.shared.makeRequest(with: url, httpMethod: .get) { [unowned self] result in
            switch result {
            case .success(let data):
                if let profileImage = UIImage(data: data) {
                    UserDetailUtil.shared.cache.setObject(profileImage, forKey: cacheKey)
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
