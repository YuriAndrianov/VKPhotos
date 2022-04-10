//
//  API.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 09.04.2022.
//

import Foundation

struct API {
    static let scheme = "https"
    static let host = "api.vk.com"
    static let version = "5.131"
    static let method = "/method/photos.get"
    
    static private var params: [String: String] = {
        guard let token = AuthService.shared.token else { return [:] }
        return [
            "owner_id": "-128666765",
            "album_id": "266276915",
            "access_token": token,
            "v": version
        ]
    }()
    
    static var url: URL? = {
        return url(method: method, params: params)
    }()
    
    static private func url(method: String, params: [String: String]) -> URL? {
        // https://api.vk.com/method/METHOD?PARAMS&access_token=TOKEN&v=V
        var components = URLComponents()
        components.scheme = API.scheme
        components.host = API.host
        components.path = method
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        return components.url
    }
}
