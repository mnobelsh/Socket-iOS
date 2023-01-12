//
//  DashboardViewController.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//  Copyright (c) 2023 All rights reserved.
//

import UIKit
import Combine
import SnapKit

final class DashboardViewController: UIViewController {
    
    private(set) var viewModel: DashboardViewModel!
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private var viewModelResponse: DashboardViewModelResponse?
    private var receiverList: [UserModel] = []
    private var typingUsernames: [String] = [] {
        didSet {
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
        tableView.register(ChatRoomTableCell.self, forCellReuseIdentifier: ChatRoomTableCell.reuseIdentifier)
        return tableView
    }()
    
    init(viewModel: DashboardViewModel) {
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
        viewModel.viewWillAppear()
        setNavigationBarTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewWillDisappear()
        navigationItem.title = ""
    }
    
}

// MARK: Private Functions
private extension DashboardViewController {
    
    func setupViewDidLoad() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func bindViewModel() {
        viewModel.$receiverList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] receiverList in
                self?.didReceiveReceiverList(receivers: receiverList)
            }
            .store(in: &cancellables)
        viewModel.$typingUsernames
            .receive(on: DispatchQueue.main)
            .sink { [weak self] typingUsernames in
                self?.typingUsernames = typingUsernames
            }
            .store(in: &cancellables)
        viewModel.$response
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.didReceiveViewModelResponse(response)
            }
            .store(in: &cancellables)
    }
    
    func didReceiveReceiverList(receivers: [UserModel]) {
        self.receiverList = receivers
        reloadTableView()
    }
    
    func reloadTableView() {
        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
    
    func didReceiveViewModelResponse(_ response: DashboardViewModelResponse?) {
        viewModelResponse = response
        setNavigationBarTitle()
    }
    
    func setNavigationBarTitle() {
        switch viewModelResponse {
        case .userLoggedIn:
            let username = AppState.shared.username ?? ""
            setNavigationTitle(largeTitle: "Hello, \(username)")
        default:
            setNavigationTitle(largeTitle: "MyChat")
        }
    }
    
    func navigateToChatRoom(receiverUser: UserModel) {
        let chatRoomViewModel: ChatRoomViewModel = ChatRoomViewModel(
            request: .init(receiverUser: receiverUser)
        )
        let chatRoomController: ChatRoomViewController = ChatRoomViewController(viewModel: chatRoomViewModel)
        navigationController?.pushViewController(chatRoomController, animated: true)
    }
    
}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receiverList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomTableCell.reuseIdentifier, for: indexPath) as? ChatRoomTableCell else { return UITableViewCell() }
        let user =  receiverList[indexPath.row]
        cell.setCell(
            withUser: user,
            subtitle: typingUsernames.contains(user.username) ? "Typing a message..." : nil
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToChatRoom(receiverUser: receiverList[indexPath.row])
    }
    
}
