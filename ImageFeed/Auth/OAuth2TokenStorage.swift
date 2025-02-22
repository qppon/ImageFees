//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Jojo Smith on 12/29/24.
//

import UIKit
import SwiftKeychainWrapper
final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let storage: UserDefaults = .standard
    private init() {}
    
    var bearerToken: String? {
        get {
            KeychainWrapper.standard.string(forKey: "Auth token")
        }
        set {
            guard let token = newValue else {
                print("nil while saving token")
                return
            }
            let isSuccess = KeychainWrapper.standard.set(token, forKey: "Auth token")
            guard isSuccess else {
                print("error while saving token")
                return
            }
        }
    }
    
    func removeToken() {
        KeychainWrapper.standard.removeObject(forKey: "Auth token")
    }
}
