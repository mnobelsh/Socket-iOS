//
//  ChatRoomViewModel.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//  Copyright (c) 2023 All rights reserved.
//

import Foundation
import LetterAvatarKit

struct ChatRoomViewModelRequest {
    var receiverUser: UserModel
}

protocol ChatRoomViewModelDelegate: AnyObject {
}

enum ChatRoomViewModelResponse {
}

protocol ChatRoomViewModelInput {
    func viewDidLoad()
    func didTyping(text: String?)
    func didEndTyping(text: String?)
    func sendMessage()
    func didSelectImage(data: Data?)
}

final class ChatRoomViewModel {

    weak var delegate: ChatRoomViewModelDelegate?
    let request: ChatRoomViewModelRequest
    var response: ChatRoomViewModelResponse?
    private var message: String?
    private var imageData: Data?
    
    @Inject private var socketProvider: SocketProvider
    
    @Published var currentUser: UserModel?
    @Published var receiverIsTyping: Bool
    @Published var messageList: [MessageModel]

    init(request: ChatRoomViewModelRequest) {
        self.request = request
        self.receiverIsTyping = false
        self.messageList = []
    }

}

// MARK: Private Functions
private extension ChatRoomViewModel {
    
    @objc
    func didReceiveMessageListNotification(_ notification: NSNotification) {
        guard let messages = notification.userInfo?["messages"] as? [MessageModel] else { return }
        let messageResult = messages.filter {
            $0.receiverUsername == request.receiverUser.username || $0.senderUsername == request.receiverUser.username
        }
        messageList = messageResult
    }
    
}

// MARK: ChatRoomViewModel + ChatRoomViewModelInput
extension ChatRoomViewModel: ChatRoomViewModelInput {

    func viewDidLoad() {
        socketProvider.startChatRoom()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMessageListNotification(_:)),
            name: .newMessageNotification,
            object: nil
        )
        guard let currentUsername = AppState.shared.username else { return }
        socketProvider.getUser(byUsername: currentUsername) { [weak self] user in
            guard var currentUser = user else { return }
            currentUser.avatarImageData = LetterAvatarMaker()
                .setUsername(currentUser.username.uppercased()).build()?.pngData()
            self?.currentUser = currentUser
        }
    }
    
    func didTyping(text: String?) {
        self.message = text
        socketProvider.sendTypingStatus()
    }
    
    func didEndTyping(text: String?) {
        self.message = text
        socketProvider.endTypingStatus()
    }
    
    func sendMessage() {
        socketProvider.sendMessage(
            receiverUsername: request.receiverUser.username,
            message: message ?? "",
            imageData: imageData ?? Data(),
            date: Date()
        )
        imageData = nil
    }
    
    func didSelectImage(data: Data?) {
        imageData = data
    }

}

// MARK: ChatRoomViewModel + ChatRoomViewModelDelegate
extension ChatRoomViewModel: ChatRoomViewModelDelegate {
    
}

