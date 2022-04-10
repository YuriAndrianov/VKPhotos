//
//  AuthService.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 08.04.2022.
//
import Foundation
import VK_ios_sdk
import UIKit

protocol AuthServiceDelegate: AnyObject {
    
    func authorizationStart()
    func authorizationShouldPresent(viewController: UIViewController)
    func authorizationDidFinish()
    func authorizationDidFail(with error: Error)
    func userDidLogOut()
    
}

final class AuthService: NSObject {
    
    static let shared = AuthService()
    
    private let appId = "8131164"
    private let vkSdk: VKSdk
    private let scope = ["offline"]
    
    weak var delegate: AuthServiceDelegate?
    
    var token: String? {
        return VKSdk.accessToken().accessToken
    }
    
    override private init() {
        vkSdk = VKSdk.initialize(withAppId: appId)
        super.init()
        vkSdk.register(self)
        vkSdk.uiDelegate = self
    }
    
    func wakeUpSession() {
        VKSdk.wakeUpSession(scope) { [weak self] state, error in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            
            guard let self = self else { return }
            
            switch state {
            case .initialized: self.delegate?.authorizationStart()
            case .authorized: self.delegate?.authorizationDidFinish()
            default: self.delegate?.userDidLogOut()
            }
        }
    }
    
    func endSession() {
        delegate?.userDidLogOut()
    }
    
    func startAuthorization() {
        VKSdk.authorize(scope)
    }
     
}

// MARK: - VKSdk delegates

extension AuthService: VKSdkDelegate {
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if result.token != nil {
            delegate?.authorizationDidFinish()
        } else if let error = result.error {
            delegate?.authorizationDidFail(with: error)
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        delegate?.userDidLogOut()
    }
    
}

extension AuthService: VKSdkUIDelegate {
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        delegate?.authorizationShouldPresent(viewController: controller)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {}
    
}
