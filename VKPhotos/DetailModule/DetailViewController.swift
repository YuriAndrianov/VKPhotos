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
    private var zoomingImageView: PhotoImageView?
    private var startingFrame: CGRect?
    private var blackBGView: UIView?
    
    private lazy var photoImage: PhotoImageView = {
        let iv = PhotoImageView(frame: .zero)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                       action: #selector(tapToZoomIn(_:))))
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
    
    // MARK: - UI configuration
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action,
                                          target: self,
                                          action: #selector(shareButtonTapped(_:)))
        navigationItem.rightBarButtonItem = shareButton
        
        // setting title
        guard let photoItems = photoItems,
              let id = id,
              let chosenItem = photoItems.first(where: { $0.id == id }) else { return }
        
        let interval = TimeInterval(chosenItem.date)
        let date = Date(timeIntervalSince1970: interval)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_EN".localized())
        formatter.dateFormat = "MMM d YYYY".localized()
        
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
    
    // MARK: - Helpers
    
    private func scrollToSelectedPhoto() {
        guard let photoItems = photoItems,
              let id = id,
              let idIndex = photoItems.firstIndex(where: { $0.id == id }) else { return }
        let selectedIndexPath = IndexPath(row: idIndex, section: 0)
        
        collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc private func shareButtonTapped(_ sender: UIBarButtonItem) {
        guard let image = photoImage.image else { return }
        
        let shareVC = UIActivityViewController(activityItems: [image],
                                               applicationActivities: nil)
        shareVC.completionWithItemsHandler = { [weak self] _, success, _, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Error".localized(), message: error.localizedDescription)
                print(error.localizedDescription)
                return
            }
            
            if success {
                self.showAlert(title: "Congratulations!".localized(),
                               message: "You have successfully shared the photo".localized())
            }
        }
        present(shareVC, animated: true)
    }
    
    // MARK: - Handle zooming and pinching, first tap to show the whole photo then it is allowed to pinch, tap on photo again to return
    
    @objc private func tapToZoomIn(_ sender: UITapGestureRecognizer) {
        guard let viewToZoomIn = sender.view as? PhotoImageView,
              let photoItems = photoItems,
              let id = id,
              let chosenItem = photoItems.first(where: { $0.id == id }) else { return }
        
        let width = CGFloat(chosenItem.properSize.width)
        let height = CGFloat(chosenItem.properSize.height)
        
        startingFrame = viewToZoomIn.superview?.convert(viewToZoomIn.frame, to: nil)
        
        guard let startingFrame = startingFrame,
              let keyWindow = UIApplication
                .shared
                .connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else { return }
        
        blackBGView = UIView(frame: keyWindow.frame)
        guard let blackBGView = blackBGView else { return }
        blackBGView.backgroundColor = .label
        blackBGView.alpha = 0
        keyWindow.addSubview(blackBGView)
        
        zoomingImageView = PhotoImageView(frame: startingFrame)
        
        guard let image = viewToZoomIn.image,
              let zoomingImageView = zoomingImageView else { return }
        
        zoomingImageView.setImage(image)
        zoomingImageView.contentMode = .scaleAspectFit
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapToZoomOut(_:))))
        zoomingImageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchToZoom(_:))))
        keyWindow.addSubview(zoomingImageView)
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseIn,
                       animations: {
            blackBGView.alpha = 1
            
            let newHeight = height / width * keyWindow.frame.width
            zoomingImageView.frame = CGRect(x: 0,
                                            y: 0,
                                            width: keyWindow.frame.width,
                                            height: newHeight)
            
            zoomingImageView.center = keyWindow.center
        })
    }
    
    @objc private func tapToZoomOut(_ sender: UITapGestureRecognizer) {
        guard let viewToZoomOut = sender.view as? PhotoImageView,
              let startingFrame = startingFrame else { return }
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseIn,
                       animations: {
            viewToZoomOut.frame = startingFrame
            
            guard let blackBGView = self.blackBGView else { return }
            blackBGView.alpha = 0
            viewToZoomOut.removeFromSuperview()
        })
    }
    
    @objc private func pinchToZoom(_ sender: UIPinchGestureRecognizer) {
        guard let viewToZoomOut = sender.view as? PhotoImageView,
              let startingFrame = startingFrame else { return }
        
        if sender.state == .changed {
            let scale = sender.scale
            viewToZoomOut.frame = CGRect(x: 0,
                                         y: 0,
                                         width: startingFrame.width * scale,
                                         height: startingFrame.height * scale)
            viewToZoomOut.center = sender.location(in: view)
        }
    }
    
}

// MARK: - collectionView delegate

extension DetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = photoItems?[indexPath.row] else { return }
        id = item.id
        photoImage.setImage(from: item.url)
        scrollToSelectedPhoto()
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
