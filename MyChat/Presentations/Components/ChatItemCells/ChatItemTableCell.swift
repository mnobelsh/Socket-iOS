//
//  ChatItemTableCell.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import UIKit
import SnapKit

class ChatItemTableCell: UITableViewCell {
    
    enum ContentOrientation {
        case right, left
    }

    private var orientation: ContentOrientation = .left
    private let imageSize: CGFloat = 40
    
    // SUBVIEWS
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "Avenir-Medium", size: 16)
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "Avenir-Light", size: 12)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    lazy var contentContainerView: UIView = UIView()
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = imageSize/2
        contentContainerView.layer.cornerRadius = 10
        switch orientation {
        case .left:
            contentContainerView.layer.maskedCorners = [
                .layerMinXMinYCorner,.layerMaxXMaxYCorner,.layerMaxXMinYCorner
            ]
        case .right:
            contentContainerView.layer.maskedCorners = [
                .layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner
            ]
        }

    }
    
    private func setupContentContainerView(orientation: ContentOrientation) {
        contentLabel.textAlignment = orientation == .right ? .right : .left
        contentContainerView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    func setupView(orientation: ContentOrientation) {
        self.orientation = orientation
        timeLabel.textAlignment = orientation == .right ? .right : .left
        setupContentContainerView(orientation: orientation)
        contentView.addSubview(profileImageView)
        contentView.addSubview(contentContainerView)
        contentView.addSubview(timeLabel)
        profileImageView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(8)
            make.height.width.equalTo(imageSize)
            switch orientation {
            case .left: make.leading.equalToSuperview().offset(10)
            case .right: make.trailing.equalToSuperview().inset(10)
            }
            make.bottom.equalToSuperview().inset(8)
        }
        contentContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            switch orientation {
            case .left:
                make.leading.equalTo(profileImageView.snp.trailing).offset(5)
                make.trailing.lessThanOrEqualToSuperview().offset(-10)
            case .right:
                make.trailing.equalTo(profileImageView.snp.leading).offset(-5)
                make.leading.greaterThanOrEqualToSuperview().offset(10)
            }
            make.bottom.equalTo(timeLabel.snp.top).offset(-2)
        }
        timeLabel.snp.makeConstraints { make in
            switch orientation {
            case .left: make.leading.equalTo(profileImageView.snp.trailing).offset(5)
            case .right: make.trailing.equalTo(profileImageView.snp.leading).offset(-5)
            }
            make.bottom.equalTo(profileImageView)
        }
    }
    
    func setCell(user: UserModel, message: MessageModel) {
        contentLabel.text = message.message
        timeLabel.text = message.getDate().toString()
        if let imageData = user.avatarImageData {
            profileImageView.image = UIImage(data: imageData)
            profileImageView.setNeedsLayout()
            profileImageView.layoutIfNeeded()
        }
    }

}
