//
//  Array.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import Foundation

extension Array where Element == Any {
    
    func asData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
    
}

