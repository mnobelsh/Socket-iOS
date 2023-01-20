//
//  ChatRoomViewController.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//  Copyright (c) 2023 All rights reserved.
//

import UIKit
import Combine
import PhotosUI

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
        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 140, right: 0)
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
    private lazy var selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(
            UIImage(systemName: "photo.fill")?.withTintColor(.systemBlue),
            for: .normal
        )
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(onSelectImageDidTap(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var imagePreviewContainerView = {
        let view = ImagePreviewContainerView()
        view.delegate = self
        return view
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
        view.addSubview(imagePreviewContainerView)
        view.addSubview(inputContainerView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        setImagePreview(isHidden: true, image: nil)
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
                self?.scrollToBottom()
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
        inputContainerView.addSubview(selectImageButton)
        inputContainerView.addSubview(inputMessageTextField)
        inputContainerView.addSubview(sendButton)
        
        selectImageButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(5)
            make.width.height.equalTo(30)
            make.centerY.equalTo(inputMessageTextField)
            make.leading.equalToSuperview().offset(16)
        }
        inputMessageTextField.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(10)
            make.height.equalTo(40)
            make.leading.equalTo(selectImageButton.snp.trailing).offset(10)
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
    
    func scrollToBottom()  {
        guard !messageList.isEmpty else { return }
        let lastIndexPath: IndexPath = IndexPath(row: messageList.count - 1, section: 0)
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.tableView.scrollToRow(at: lastIndexPath, at: .top, animated: true)
        }
    }
    
    func presentImagePicker() {
        if #available(iOS 14.0, *) {
            var config: PHPickerConfiguration = PHPickerConfiguration()
            config.filter = .any(of: [.images])
            let imagePicker: PHPickerViewController = PHPickerViewController(configuration: config)
            imagePicker.delegate = self
            present(imagePicker, animated: true)
        } else {
            let imagePicker: UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            present(imagePicker, animated: true)
        }
    }
    
    func setImagePreview(isHidden: Bool, image: UIImage?) {
        DispatchQueue.main.async {
            if isHidden {
                UIView.animate(withDuration: 0.25) {
                    self.imagePreviewContainerView.snp.remakeConstraints { make in
                        make.horizontalEdges.equalToSuperview()
                        make.top.equalTo(self.inputContainerView.snp.top)
                    }
                    self.view.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.imagePreviewContainerView.snp.remakeConstraints { make in
                        make.horizontalEdges.equalToSuperview()
                        make.bottom.equalTo(self.inputContainerView.snp.top)
                    }
                    self.view.layoutIfNeeded()
                }
            }
            self.imagePreviewContainerView.setImage(image)
        }
    }
    
    @objc
    func onSelectImageDidTap(_ sender: UIButton) {
        presentImagePicker()
    }
    
    @objc
    func onSendButtonDidTap(_ sender: UIButton) {
        viewModel.sendMessage()
        inputMessageTextField.text = nil
        inputMessageTextField.resignFirstResponder()
        setImagePreview(isHidden: true, image: nil)
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

extension ChatRoomViewController:
    UIImagePickerControllerDelegate,
    PHPickerViewControllerDelegate,
    UINavigationControllerDelegate {
    
    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let item = results.map({ $0.itemProvider }).first,
              item.canLoadObject(ofClass: UIImage.self)
        else { return }
        item.loadObject(ofClass: UIImage.self) { [weak self] loadResult, _ in
            guard let selectedImage: UIImage = loadResult as? UIImage,
                  let selectedImageData: Data = selectedImage.pngData()
            else { return }
            self?.viewModel.didSelectImage(data: selectedImageData)
            self?.setImagePreview(isHidden: false, image: selectedImage)
        }
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        guard let selectedImage: UIImage = info[.originalImage] as? UIImage,
              let selectedImageData: Data = selectedImage.pngData() else { return }
        viewModel.didSelectImage(data: selectedImageData)
        setImagePreview(isHidden: false, image: selectedImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}

extension ChatRoomViewController: ImagePreviewContainerViewDelegate {
    
    func imagePreviewContainerView(_ view: ImagePreviewContainerView, didRemoveImage removedImage: UIImage?) {
        setImagePreview(isHidden: true, image: nil)
        viewModel.didSelectImage(data: nil)
    }
    
}
