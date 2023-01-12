//
//  SocketProvider.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import Foundation
import SocketIO

final class SocketProvider {

    private let manager: SocketManager
    private let socket: SocketIOClient
    
    ///Replace with your own localhost server
    private let localhost: String = "http://192.168.100.187:3000"
    
    init() {
        guard let clientUrl: URL = URL(string: localhost) else  { fatalError() }
        manager = SocketManager(socketURL: clientUrl, config: [.log(true), .compress])
        socket = manager.defaultSocket
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            self?.observeDataUpdate()
            guard let username = AppState.shared.username else {
                NotificationCenter.default.post(name: .userDidLogOut, object: nil)
                return
            }
            self?.registerUser(withUsername: username)
        }
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func terminateConnection() {
        socket.disconnect()
    }
    
    func registerUser(withUsername username: String) {
        socket.emit("connectUser", username)
        AppState.shared.username = username
    }
    
    func sendTypingStatus() {
        guard let username = AppState.shared.username else { return }
        socket.emit("startType", username)
    }
    
    func endTypingStatus() {
        guard let username = AppState.shared.username else { return }
        socket.emit("stopType", username)
    }
    
    func startChatRoom() {
        guard let username = AppState.shared.username else { return }
        socket.emit("startChat", username)
    }
    
    func sendMessage(receiverUsername: String, message: String) {
        guard let username = AppState.shared.username else { return }
        socket.emit("chatMessage", username, receiverUsername, message)
    }
    
    func getAllUserList(completion: @escaping(_ userList: [UserModel]) -> Void) {
        socket.once("userList") { [weak self] response, ack in
            guard let data = self?.convertToData(from: response[0]) else {
                completion([])
                return
            }
            let userListResult: [UserModel] = data.decode() ?? []
            completion(userListResult)
        }
    }
    
    func getUser(byUsername username: String, completion: @escaping(_ user: UserModel?) -> Void) {
        socket.once("userList") { [weak self] response, ack in
            guard let data = self?.convertToData(from: response[0]) else {
                completion(nil)
                return
            }
            let userListResult: [UserModel] = data.decode() ?? []
            completion(userListResult.first(where:  { $0.username == username }))
        }
    }
    
    func getChatMessages(completion: @escaping(_ messages: [MessageModel]) -> Void) {
        socket.once("newChatMessage") { [weak self] response, ack in
            guard let data = self?.convertToData(from: response[0]),
                  let currentUsername = AppState.shared.username
            else {
                completion([])
                return
            }
            let messageList: [MessageModel] = (data.decode() ?? []).filter {
                $0.senderUsername == currentUsername || $0.receiverUsername == currentUsername
            }
            completion(messageList)
        }
    }
    
    private func observeDataUpdate() {
        socket.on("userList") { [weak self] response, ack in
            guard let data = self?.convertToData(from: response[0]) else { return }
            let userListResult: [UserModel] = data.decode() ?? []
            NotificationCenter.default.post(
                name: .didReceiveAllUserList,
                object: nil,
                userInfo: ["userList": userListResult]
            )
            if userListResult.first(where: { $0.username == AppState.shared.username }) == nil {
                AppState.shared.username = nil
                NotificationCenter.default.post(name: .userDidLogOut, object: nil)
            }
        }
        socket.on("userConnectUpdate") { [weak self] response, ack in
            guard let data = self?.convertToData(from: response[0]),
                  let user: UserModel = data.decode()
            else { return }
            NotificationCenter.default.post(
                name: .userDidConnectNotification,
                object: nil,
                userInfo: ["user": user]
            )
        }
        socket.on("userExitUpdate") { response, ack in
            guard let username: String = response[0] as? String else { return }
            NotificationCenter.default.post(
                name: .userDidDisconnectNotification,
                object: nil,
                userInfo: ["username": username]
            )
        }
        socket.on("userTypingUpdate") { response, ack  in
            guard let object = response[0] as? [String: AnyObject] else { return }
            NotificationCenter.default.post(
                name: .userOnTypingNotification,
                object: nil,
                userInfo: ["typingUsernames": Array(object.keys)]
            )
        }
        socket.on("newChatMessage") { [weak self] response, ack in
            guard let data = self?.convertToData(from: response[0]),
                  let currentUsername = AppState.shared.username
            else { return }
            let messageList: [MessageModel] = (data.decode() ?? []).filter {
                $0.senderUsername == currentUsername || $0.receiverUsername == currentUsername
            }
            NotificationCenter.default.post(
                name: .newMessageNotification,
                object: nil,
                userInfo: ["messages": messageList]
            )
        }
    }
    
    private func convertToData(from value: Any?) -> Data? {
        guard let value = value else { return nil }
        return try? JSONSerialization.data(withJSONObject: value, options: [])
    }
    
}

private extension String {
    
    
    
}
