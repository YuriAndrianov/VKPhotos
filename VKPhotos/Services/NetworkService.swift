//
//  NetworkService.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 09.04.2022.
//

import Foundation

protocol Networking {
    
    func request(from url: URL, completion: @escaping (Result<Data, Error>) -> Void)
    
}

final class NetworkService: Networking {
    
    func request(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)

        guard let dataTask = createDataTask(from: request, completion: completion) else { return }
        dataTask.resume()
    }
   
    private func createDataTask(from request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask? {
        return URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else { return }
            DispatchQueue.main.async { completion(.success(data)) }
        }
    }
    
}
