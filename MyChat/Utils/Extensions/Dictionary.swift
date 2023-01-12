//
//  Dictionary.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 12/01/23.
//

import Foundation

extension Dictionary {
    func decode<T: Decodable>() -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
