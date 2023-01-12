//
//  Date.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 12/01/23.
//

import Foundation

extension Date {
    
    func toString(format: String = "h:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
