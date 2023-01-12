//
//  SceneDelegate.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private lazy var navigationController: UINavigationController = {
        let navigationController: UINavigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.view.backgroundColor = .white
        return navigationController
    }()
    @Inject private var socketProvider: SocketProvider

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        window?.overrideUserInterfaceStyle = .light
        let dashboardViewModel: DashboardViewModel = DashboardViewModel(request: .init())
        let dashboardController: DashboardViewController = DashboardViewController(
            viewModel: dashboardViewModel
        )
        navigationController.viewControllers = [dashboardController]
        window?.rootViewController = navigationController
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogoutNotification(_:)),
            name: .userDidLogOut,
            object: nil
        )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        socketProvider.establishConnection()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        socketProvider.terminateConnection()
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    private func showInputUsernameAlert() {
        let alertController: UIAlertController = UIAlertController(
            title: "Input Your Username",
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField { textField in }
        let confirmAction: UIAlertAction = UIAlertAction(
            title: "Confirm",
            style: .default
        ) { [weak self] _ in
            guard let username = alertController.textFields?.first?.text else { return }
            guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                self?.navigationController.present(alertController, animated: true)
                return
            }
            self?.socketProvider.registerUser(withUsername: username)
            alertController.dismiss(animated: true)
        }
        alertController.addAction(confirmAction)
        navigationController.present(alertController, animated: true)
    }

    @objc
    private func userDidLogoutNotification(_ notification: NSNotification) {
        showInputUsernameAlert()
    }
    

}

