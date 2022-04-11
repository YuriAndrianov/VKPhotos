//
//  CustomError.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 11.04.2022.
//

import Foundation

enum CustomError: Error {
    
case noData
case noInternet
case unknownErr
    
}

extension CustomError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "Couldn't fetch photos from the album".localized()
        case .noInternet:
            return "No internet connection".localized()
        case .unknownErr:
            return "Something went wrong".localized()
        }
    }
    
}
