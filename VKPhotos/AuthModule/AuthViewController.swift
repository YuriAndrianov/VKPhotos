//
//  AuthViewController.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 08.04.2022.
//

import UIKit

class AuthViewController: UIViewController {
    
    var authService: AuthService?
    
    init(authService: AuthService) {
        super.init(nibName: nil, bundle: nil)
        self.authService = authService
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    @IBAction func enterVKButtonTapped(_ sender: Any) {
        authService?.wakeUpSession()
    }
}
