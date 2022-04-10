//
//  PhotoFetcher.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 09.04.2022.
//

import UIKit

protocol PhotoFetching {
    
    func getPhotoItems(_ completion: @escaping (Result<[PhotoItem], Error>) -> Void)
    
}

final class PhotoFetcher: PhotoFetching {
    
    private var networkService: Networking?
    
    init(networkService: Networking) {
        self.networkService = networkService
    }
    
    func getPhotoItems(_ completion: @escaping (Result<[PhotoItem], Error>) -> Void) {
        guard let url = API.url else { return }
        
        networkService?.request(from: url, completion: { [weak self] result in
            switch result {
            case .success(let data):
                guard let decoded = self?.decodeJSON(type: PhotoResponseWrapped.self, from: data) else { return }
                DispatchQueue.main.async { completion(.success(decoded.response.items)) }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        })
    }
    
    private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let data = from,
              let response = try? decoder.decode(type.self, from: data) else { return nil }
        return response
    }
    
}
