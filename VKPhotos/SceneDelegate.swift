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
        window?.makeKeyAndVisible()
        
        let authService = AuthService.shared
        authService.delegate = self
        authService.wakeUpSession()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            VKSdk.processOpen(url, fromApplication: UIApplication.OpenURLOptionsKey.sourceApplication.rawValue)
        }
    }
    
}

// MARK: - AuthServiceDelegate

extension SceneDelegate: AuthServiceDelegate {
    
    func authorizationStart() {
        let authVC = AuthViewController()
        window?.rootViewController = authVC
    }
    
    func authorizationShouldPresent(viewController: UIViewController) {
        window?.rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func authorizationDidFinish() {
        let networkService = NetworkService()
        let photoFetcher = PhotoFetcher(networkService: networkService)
        let photosVC = PhotosViewController(photoFetcher: photoFetcher)
        let navVC = UINavigationController(rootViewController: photosVC)
        window?.rootViewController = navVC
    }
    
    func userDidLogOut() {
        VKSdk.forceLogout()
        let authVC = AuthViewController()
        window?.rootViewController = authVC
    }
    
    func authorizationDidFail(with error: Error) {
        print(error.localizedDescription)
        
        let alertVC = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Ок", style: .default, handler: { [weak self] _ in
            self?.userDidLogOut()
        }))
        
        window?.rootViewController?.present(alertVC, animated: true, completion: nil)
    }
    
}
