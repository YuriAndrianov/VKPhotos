//
//  PhotosViewController.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 08.04.2022.
//

import UIKit
import VK_ios_sdk

final class PhotosViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    @objc private func logOutButtonTapped() {
        let logOutAlertVC = UIAlertController(title: nil, message: "Вы действительно хотите выйти?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Да", style: .default) { _ in
            AuthService.shared.endSession()
        }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        logOutAlertVC.addAction(confirmAction)
        logOutAlertVC.addAction(cancelAction)
        
        present(logOutAlertVC, animated: true, completion: nil)
    }
    
    private func setupNavBar() {
        title = "Photos"
        let logOutButton = UIBarButtonItem(title: "Выход",
                                           style: .done,
                                           target: self,
                                           action: #selector(logOutButtonTapped))
        
        navigationItem.rightBarButtonItem = logOutButton
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.prefersLargeTitles = false
    }

}
