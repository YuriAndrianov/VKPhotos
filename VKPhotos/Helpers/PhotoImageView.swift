//
//  PhotoImageView.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 09.04.2022.
//

import UIKit

class PhotoImageView: UIImageView {
    
    private let networkService = NetworkService()
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
        spinner.center = center
    }
    
    func set(from url: String) {
        guard let url = URL(string: url) else { return }
        
        networkService.request(from: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                    self.spinner.stopAnimating()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
}
