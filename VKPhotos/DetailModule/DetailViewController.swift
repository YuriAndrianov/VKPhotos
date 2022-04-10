//
//  DetailViewController.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 10.04.2022.
//

import UIKit

final class DetailViewController: UIViewController {
    
    private var photoItems: [PhotoItem]?
    private var id: Int?
    
    private lazy var photoImage: PhotoImageView = {
        let iv = PhotoImageView(frame: .zero)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .horizontal
        layout.collectionView?.backgroundColor = .systemBackground
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(
            UINib(nibName: "PhotoCollectionViewCell", bundle: Bundle.main),
            forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier
        )
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    init(photoItems: [PhotoItem], id: Int) {
        super.init(nibName: nil, bundle: nil)
        self.photoItems = photoItems
        self.id = id
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setPhotoImage()
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        photoImage.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        photoImage.center = view.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToSelectedPhoto()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // setting title
        guard let photoItems = photoItems,
              let id = id,
              let chosenItem = photoItems.first(where: { $0.id == id }) else { return }

        let interval = TimeInterval(chosenItem.date)
        let date = Date(timeIntervalSince1970: interval)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM YYYY"
        
        title = formatter.string(from: date)
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delaysContentTouches = false
        
        NSLayoutConstraint.activate([
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 60),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func scrollToSelectedPhoto() {
        guard let photoItems = photoItems,
              let id = id,
              let idIndex = photoItems.firstIndex(where: { $0.id == id }) else { return }
        
        let selectedIndexPath = IndexPath(row: idIndex, section: 0)
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    private func setPhotoImage() {
        view.addSubview(photoImage)

        guard let photoItems = photoItems,
              let id = id,
              let chosenItem = photoItems.first(where: { $0.id == id }) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.photoImage.setImage(from: chosenItem.url)
        }
    }

}

// MARK: - collectionView delegate

extension DetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = photoItems?[indexPath.row] else { return }
        id = item.id
        photoImage.setImage(from: item.url)
    }

}

// MARK: - collectionView datasource

extension DetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        
        if let photoItems = photoItems,
           let id = id {
            let item = photoItems[indexPath.row]
            let isSelected = item.id == id
            cell.configure(with: item, isSelected: isSelected)
        }
        return cell
    }
    
}

// MARK: - collectionViewDelegateFlowLayout

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = 56
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}
