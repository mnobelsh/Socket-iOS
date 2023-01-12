//
//  Data.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import Foundation

extension Data {
    
    func decode<T: Decodable>() -> T? {
        return try? JSONDecoder().decode(T.self, from: self)
    }
    
}
