//
//  ReceiverChatItemTableCell.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import UIKit

class ReceiverChatItemTableCell: ChatItemTableCell {

    static let reuseIdentifier: String = String(describing: ReceiverChatItemTableCell.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView(orientation: .left)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setCell(user: UserModel, message: MessageModel) {
        super.setCell(user: user, message: message)
        contentContainerView.backgroundColor = .systemGray
    }

}
