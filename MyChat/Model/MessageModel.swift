//
//  MessageModel.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 12/01/23.
//

import Foundation

struct MessageModel: Codable {
    var senderUsername: String
    var receiverUsername: String
    var message: String
    var imageBase64String: String?
    var date: String
    
    func getDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd/yyyy HH:mm:ss a"
        return dateFormatter.date(from: self.date) ?? Date()
    }
    func imageData() -> Data? {
        guard let imageDataString = imageBase64String,
              let nsData = NSData(base64Encoded: imageDataString)
        else { return nil }
        return Data(referencing: nsData)
    }
}
