//
//  PhotoImageView.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 09.04.2022.
//

import UIKit

final class PhotoImageView: UIImageView {

    private let spinner = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        addSubview(spinner)
        spinner.style = .large
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
    }
    
    override func layoutSubviews() {
        spinner.center = center
    }
    
    func setImage(from url: String) {
        guard let url = URL(string: url) else { return }
        
        // trying to get image from cache
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            self.image = UIImage(data: cachedResponse.data)
            self.spinner.stopAnimating()
            return
        }
        
        // downloading image
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let data = data,
                   let response = response {
                    self.image = UIImage(data: data)
                    self.cacheData(response: response, data: data) // saving to cache
                    self.spinner.stopAnimating()
                }
            }
        }.resume()
    }
    
    private func cacheData(response: URLResponse, data: Data) {
        guard let responseURL = response.url else { return }
        let cachedResponse = CachedURLResponse(response: response, data: data)
        URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: responseURL))
    }
    
}
