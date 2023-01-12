//
//  Injector.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import Foundation
import Swinject

@propertyWrapper
struct Inject<T> {
    private var component: T
  
    init(_ name: String? = nil) {
      self.component = DIContainer.shared.container.resolve(T.self, name: name)!
    }
  
    public var wrappedValue: T {
        get { return component}
        mutating set { component = newValue }
    }
}
