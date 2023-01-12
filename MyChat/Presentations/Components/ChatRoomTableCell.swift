//
//  ChatRoomTableCell.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import UIKit
import SnapKit

final class ChatRoomTableCell: UITableViewCell {
    
    static let reuseIdentifier: String = String(describing: ChatRoomTableCell.self)
    private let imageSize: CGFloat = 45
    private let indicatorSize: CGFloat = 15
    
    // SUBVIEWS
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray4
        return imageView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "Avenir-Bold", size: 16)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont(name: "Avenir", size: 12)
        label.textAlignment = .left
        label.textColor = .darkGray
        return label
    }()
    private var indicatorView: UIView = UIView()
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel,subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(contentStackView)
        contentView.addSubview(separatorView)
        contentView.addSubview(indicatorView)
        
        profileImageView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(12)
            make.width.height.equalTo(imageSize)
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
        indicatorView.snp.makeConstraints { make in
            make.leading.top.equalTo(profileImageView).offset(-2)
            make.width.height.equalTo(indicatorSize)
        }
        contentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualToSuperview().offset(-5)
        }
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = imageSize/4
        profileImageView.layer.cornerCurve = .circular
        indicatorView.layer.cornerRadius = indicatorSize/2
    }
    
    func setCell(withUser user: UserModel, subtitle: String? = nil) {
        titleLabel.text = user.username
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        indicatorView.backgroundColor = user.isConnected ? .systemGreen : .systemGray4
        if let imageData = user.avatarImageData {
            profileImageView.image = UIImage(data: imageData)
            profileImageView.setNeedsLayout()
            profileImageView.layoutIfNeeded()
        }
    }
    
}
