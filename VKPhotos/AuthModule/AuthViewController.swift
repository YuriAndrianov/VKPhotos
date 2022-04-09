//
//  AuthViewController.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 08.04.2022.
//

import UIKit
import VK_ios_sdk

final class AuthViewController: UIViewController {
    
    @IBOutlet private weak var label: UILabel?
    private var authService: AuthService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        label?.text = "Mobile Up\nGallery"
        authService = AuthService.shared
    }

    @IBAction func enterVKButtonTapped(_ sender: Any) {
        authService?.startAuthorization()
    }
}
