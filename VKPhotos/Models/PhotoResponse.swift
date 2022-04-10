//
//  PhotoResponse.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 09.04.2022.
//

import Foundation

struct PhotoResponseWrapped: Codable {
    
    let response: PhotoResponse
    
}

struct PhotoResponse: Codable {
    
    var items: [PhotoItem]
    
}

struct PhotoItem: Codable {
    
    var id: Int
    var date: Int
    var sizes: [Size]
    
    var url: String {
        return getProperSize().url
    }
    
    private func getProperSize() -> Size {
        if let sizeX = sizes.first(where: { $0.type == "x" }) {
            return sizeX
        } else if let lagestSize = sizes.last {
            return lagestSize
        } else {
            return Size(type: "no image", url: "no url", width: 0, height: 0)
        }
    }
     
}

struct Size: Codable {
    
    var type: String
    var url: String
    var width: Int
    var height: Int

}
