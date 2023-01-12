//
//  UserModel.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import Foundation

struct UserModel: Codable {
    
    var id: String
    var username: String
    var isConnected: Bool
    var avatarImageData: Data?
    
}
