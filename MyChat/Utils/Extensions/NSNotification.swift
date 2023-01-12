//
//  NSNotification.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 12/01/23.
//

import UIKit

extension NSNotification.Name {
    
    static let userDidLogOut: NSNotification.Name =
    NSNotification.Name("userDidLogOut")
    static let didReceiveAllUserList: NSNotification.Name =
    NSNotification.Name("didReceiveAllUserList")
    static let userDidConnectNotification: NSNotification.Name =
    NSNotification.Name("userDidConnectNotification")
    static let userDidDisconnectNotification: NSNotification.Name =
    NSNotification.Name("userDidDisconnectNotification")
    static let userOnTypingNotification: NSNotification.Name =
    NSNotification.Name("userOnTypingNotification")
    static let userDidEndTypingNotification: NSNotification.Name =
    NSNotification.Name("userDidEndTypingNotification")
    static let newMessageNotification: NSNotification.Name =
    NSNotification.Name("newMessageNotification")
}
