//
//  String+localized.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 11.04.2022.
//

import Foundation

extension String {
    
    func localized() -> String {
        return NSLocalizedString(
            self,
            tableName: "Localizable",
            bundle: .main,
            value: self,
            comment: self
        )
    }
    
}
