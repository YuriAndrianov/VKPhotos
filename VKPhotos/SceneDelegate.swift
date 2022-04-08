//
//  SceneDelegate.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 08.04.2022.
//

import UIKit
import VK_ios_sdk

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        let authService = AuthService()
        authService.delegate = self
        
        let authVC = AuthViewController(authService: authService)
        
        window?.rootViewController = authVC
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            VKSdk.processOpen(url, fromApplication: UIApplication.OpenURLOptionsKey.sourceApplication.rawValue)
        }
    }
    
}

// MARK: - AuthServiceDelegate

extension SceneDelegate: AuthServiceDelegate {
    
    func authServiceShouldPresent(viewController: UIViewController) {
        window?.rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func authServiceFinished() {
        let photosVC = PhotosViewController()
        let navVC = UINavigationController(rootViewController: photosVC)
        
        window?.rootViewController = navVC 
    }
    
    func authServiceFailed() {
        
    }
    
}
