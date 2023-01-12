//
//  ChatRoomViewController.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//  Copyright (c) 2023 All rights reserved.
//

import UIKit
import Combine

final class ChatRoomViewController: UIViewController {
    
    private(set) var viewModel: ChatRoomViewModel!
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private var currentUser: UserModel? {
        didSet {
            reloadTableView()
        }
    }
    private var messageList: [MessageModel] = [] {
        didSet{
            reloadTableView()
        }
    }
    
    // SUBVIEWS
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0)
        tableView.register(SenderChatItemTableCell.self, forCellReuseIdentifier: SenderChatItemTableCell.reuseIdentifier)
        tableView.register(ReceiverChatItemTableCell.self, forCellReuseIdentifier: ReceiverChatItemTableCell.reuseIdentifier)
        return tableView
    }()
    private lazy var inputMessageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type your message here..."
        textField.delegate = self
        return textField
    }()
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(
            UIImage(systemName: "paperplane.circle.fill")?.withTintColor(.systemBlue),
            for: .normal
        )
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(onSendButtonDidTap(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var inputContainerView: UIView = UIView()
    
    init(viewModel: ChatRoomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewDidLoad()
        viewModel.viewDidLoad()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewWillAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        inputContainerView.layer.shadowColor = UIColor.gray.cgColor
        inputContainerView.layer.shadowOffset = CGSize(width: 0, height: -1.5)
        inputContainerView.layer.shadowRadius = 3.5
        inputContainerView.layer.shadowOpacity = 0.25
    }
    
}

// MARK: Private Functions
private extension ChatRoomViewController {
    
    func setupViewDidLoad() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        configureInputContainerView()
    }
    
    func bindViewModel() {
        viewModel.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentUser in
                self?.currentUser = currentUser
            }
            .store(in: &cancellables)
        viewModel.$messageList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.messageList = messages
            }
            .store(in: &cancellables)
    }
    
    func setupViewWillAppear() {
        setNavigationTitle(title: viewModel.request.receiverUser.username)
    }
    
    func reloadTableView() {
        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
    
    func configureInputContainerView() {
        inputContainerView.backgroundColor = .white
        inputContainerView.addSubview(inputMessageTextField)
        inputContainerView.addSubview(sendButton)
        view.addSubview(inputContainerView)
        
        inputMessageTextField.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(10)
            make.height.equalTo(40)
            make.leading.equalToSuperview().offset(16)
            make.bottom.lessThanOrEqualToSuperview().offset(-40)
        }
        sendButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(5)
            make.width.height.equalTo(35)
            make.centerY.equalTo(inputMessageTextField)
            make.leading.equalTo(inputMessageTextField.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(16)
        }
        
        inputContainerView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    @objc
    func onSendButtonDidTap(_ sender: UIButton) {
        viewModel.sendMessage()
        inputMessageTextField.text = nil
        inputMessageTextField.resignFirstResponder()
    }
    
}

extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageList[indexPath.row]
        if message.senderUsername == AppState.shared.username {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SenderChatItemTableCell.reuseIdentifier, for: indexPath) as? SenderChatItemTableCell else { return UITableViewCell() }
            if let currentUser = self.currentUser {
                cell.setCell(user: currentUser, message: message)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReceiverChatItemTableCell.reuseIdentifier, for: indexPath) as? ReceiverChatItemTableCell else { return UITableViewCell() }
            cell.setCell(user: viewModel.request.receiverUser, message: message)
            return cell
        }
    }
    
}

extension ChatRoomViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            viewModel.didTyping(text: updatedText)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.didEndTyping(text: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
}
