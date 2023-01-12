//
//  UINavigationController.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import UIKit

extension UINavigationController {
    
    func setNavigationBar() {
        self.setNavigationBarHidden(false, animated: true)
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear
            appearance.backgroundImage = UIImage()
            appearance.shadowImage = UIImage()
            appearance.backgroundColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.shadowImage = UIImage()
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.backgroundColor = .white
            navigationBar.barTintColor = .white
        }
        navigationBar.layer.shadowColor = UIColor.darkGray.cgColor
        navigationBar.layer.shadowOffset = CGSize(width: 0, height: 3)
        navigationBar.layer.shadowRadius = 2.5
        navigationBar.layer.shadowOpacity = 0.2
        navigationBar.layer.masksToBounds = false
    }
    
}
