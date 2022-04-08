//
//  AuthService.swift
//  VKPhotos
//
//  Created by Юрий Андрианов on 08.04.2022.
//

import Foundation
import VK_ios_sdk

protocol AuthServiceDelegate: AnyObject {
    
    func authServiceShouldPresent(viewController: UIViewController)
    func authServiceFinished()
    func authServiceFailed()
    
}

class AuthService: NSObject {
    
    private let appId = "8131164"
    private let vkSdk: VKSdk
    
    weak var delegate: AuthServiceDelegate?
    
    override init() {
        vkSdk = VKSdk.initialize(withAppId: appId)
        super.init()
        vkSdk.register(self)
        vkSdk.uiDelegate = self
    }
    
    func wakeUpSession() {
        let scope = ["offline"]
        VKSdk.wakeUpSession(scope) { [weak self] state, error in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            
            guard let self = self else { return }
            
            switch state {
            case .initialized: VKSdk.authorize(scope)
            case .authorized: self.delegate?.authServiceFinished()
            default: self.delegate?.authServiceFailed()
            }
        }
    }
     
}

// MARK: - VKSdk delegates

extension AuthService: VKSdkDelegate {
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if result.token != nil {
            delegate?.authServiceFinished()
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        delegate?.authServiceFailed()
    }
    
}

extension AuthService: VKSdkUIDelegate {
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        delegate?.authServiceShouldPresent(viewController: controller)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {}
    
}
