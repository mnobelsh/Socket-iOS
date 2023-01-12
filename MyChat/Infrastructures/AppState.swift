//
//  AppState.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 12/01/23.
//

import Foundation

protocol AppStateProtocol: AnyObject {
    var username: String? { get set }
}

final class AppState: AppStateProtocol {
    
    static let shared: AppState = AppState()
    private let defaults: UserDefaults = UserDefaults.standard
    
    var username: String? {
        get {
            return defaults.string(forKey: .usernameKey)
        }
        set {
            defaults.setValue(newValue, forKey: .usernameKey)
        }
    }
    
}

private extension String {
    
    static let usernameKey = "USERNAME"
    
}
