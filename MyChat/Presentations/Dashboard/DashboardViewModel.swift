//
//  DashboardViewModel.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//  Copyright (c) 2023 All rights reserved.
//

import Foundation
import LetterAvatarKit

struct DashboardViewModelRequest {
}

protocol DashboardViewModelDelegate: AnyObject {
}

enum DashboardViewModelResponse {
    case userLoggedOut, userLoggedIn
}

protocol DashboardViewModelInput {
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func registerUser(withUsername username: String)
}

final class DashboardViewModel {

    weak var delegate: DashboardViewModelDelegate?
    let request: DashboardViewModelRequest
   
    
    @Inject private var socketProvider: SocketProvider
    
    @Published var receiverList: [UserModel]
    @Published var typingUsernames: [String]
    @Published var response: DashboardViewModelResponse?

    init(request: DashboardViewModelRequest) {
        self.request = request
        self.receiverList = []
        self.typingUsernames = []
    }

}

// MARK: Private Functions
private extension DashboardViewModel {
    
    @objc
    func userDidLogoutNotification(_ notification: NSNotification) {
        response = .userLoggedOut
    }
    
    @objc
    func didReceiveAllUserListNotification(_ notification: NSNotification) {
        guard var userList: [UserModel] = notification.userInfo?["userList"] as? [UserModel]
        else { return }
        if let currentUsername = AppState.shared.username {
            userList = userList.filter { $0.username != currentUsername }
            response = .userLoggedIn
        }
        self.receiverList = userList.map {
            var updatedUser = $0
            updatedUser.avatarImageData = LetterAvatarMaker()
                .setUsername($0.username.uppercased()).build()?.pngData()
            return updatedUser
        }
    }
    
    @objc
    func userOnTypingNotification(_ notification: NSNotification) {
        guard let typingUsernames: [String] = notification.userInfo?["typingUsernames"] as? [String]
        else { return }
        self.typingUsernames = typingUsernames
    }
    
}

// MARK: DashboardViewModel + DashboardViewModelInput
extension DashboardViewModel: DashboardViewModelInput {

    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogoutNotification(_:)),
            name: .userDidLogOut,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userOnTypingNotification(_:)),
            name: .userOnTypingNotification,
            object: nil
        )
    }
    
    func viewWillAppear() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveAllUserListNotification(_:)),
            name: .didReceiveAllUserList,
            object: nil
        )
    }
    
    func viewWillDisappear() {
        NotificationCenter.default.removeObserver(self, name: .didReceiveAllUserList, object: nil)
    }
    
    func registerUser(withUsername username: String) {
        socketProvider.registerUser(withUsername: username)
        response = .userLoggedIn
    }

}

// MARK: DashboardViewModel + DashboardViewModelDelegate
extension DashboardViewModel: DashboardViewModelDelegate {
    
}

