//
//  PhotoCollectionViewCell.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 09.04.2022.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "cell"
   
    @IBOutlet private weak var imageView: PhotoImageView?
    
    func configure(with url: String) {
        imageView?.set(from: url)
    }
    
}
