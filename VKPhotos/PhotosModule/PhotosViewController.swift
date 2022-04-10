//
//  PhotosViewController.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 08.04.2022.
//

import UIKit

final class PhotosViewController: UIViewController {
    
    private var photoItems = [PhotoItem]()
    private var photoFetcher: PhotoFetching?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        layout.collectionView?.backgroundColor = .systemBackground
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(
            UINib(nibName: "PhotoCollectionViewCell", bundle: Bundle.main),
            forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier
        )
        return cv
    }()
    
    init(photoFetcher: PhotoFetching) {
        super.init(nibName: nil, bundle: nil)
        self.photoFetcher = photoFetcher
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        configureCollectionView()
        getPhotoItems()
    }
    
    override func viewDidLayoutSubviews() {
        collectionView.frame = view.bounds
    }
    
    // MARK: - UI configuration
    
    private func setupNavBar() {
        title = "Mobile Up Gallery"
        view.backgroundColor = .systemBackground
        let logOutButton = UIBarButtonItem(title: "Выход",
                                           style: .done,
                                           target: self,
                                           action: #selector(logOutButtonTapped))
        
        navigationItem.rightBarButtonItem = logOutButton
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delaysContentTouches = false
    }
    
    // MARK: - Fetching photos
    
    private func getPhotoItems() {
        photoFetcher?.getPhotoItems({ [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                DispatchQueue.main.async {
                    self.photoItems = items
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                self.showAlert(with: error)
            }
        })
    }
    
    // MARK: - Helpers
    
    private func showAlert(with error: Error) {
        let alertVC = UIAlertController(title: "Ошибка",
                                        message: error.localizedDescription,
                                        preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc private func logOutButtonTapped() {
        let logOutAlertVC = UIAlertController(title: nil,
                                              message: "Вы действительно хотите выйти?",
                                              preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Да",
                                          style: .default) { _ in AuthService.shared.endSession() }
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        logOutAlertVC.addAction(confirmAction)
        logOutAlertVC.addAction(cancelAction)
        
        present(logOutAlertVC, animated: true, completion: nil)
    }
    
}

// MARK: - collectionView delegate

extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let detailedItem = photoItems[indexPath.row]
        
        let detailedVC = DetailViewController(photoItems: photoItems, id: detailedItem.id)
        navigationController?.pushViewController(detailedVC, animated: true)
    }
   
}

// MARK: - collectionView datasource

extension PhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        
        let item = photoItems[indexPath.row]
        cell.configure(with: item, isSelected: false)
        
        return cell
    }
    
}

// MARK: - collectionViewDelegateFlowLayout

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width / 2 - 1
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}
