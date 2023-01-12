//
//  DIContainer.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import Foundation
import Swinject

final class DIContainer {
    
    static let shared = DIContainer()
    
    var container: Container = Container()
    
    func registerContainers() {
        container.register(SocketProvider.self) { _ in SocketProvider() }.inObjectScope(.container)
    }
    
}
