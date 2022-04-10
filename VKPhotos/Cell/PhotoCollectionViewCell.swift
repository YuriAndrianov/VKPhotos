//
//  PhotoCollectionViewCell.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 09.04.2022.
//

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "cell"
    
    @IBOutlet private weak var imageView: PhotoImageView?
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = UIColor.label.cgColor
                layer.borderWidth = 4
            } else {
                layer.borderColor = UIColor.clear.cgColor
                layer.borderWidth = 0
            }
        }
    }
    
    func configure(with item: PhotoItem, isSelected: Bool) {
        let url = item.url
        imageView?.setImage(from: url)
        self.isSelected = isSelected
    }
    
}
