//
//  UIViewController.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 11/01/23.
//

import UIKit

extension UIViewController {
    
    func setNavigationTitle(title: String) {
        navigationItem.title = title
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont(name: "Avenir-Heavy", size: 20) ?? .boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBar()
    }
    
    func setNavigationTitle(largeTitle: String) {
        navigationItem.title = largeTitle
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont(name: "Avenir-Heavy", size: 30) ?? .boldSystemFont(ofSize: 30),
            .foregroundColor: UIColor.black
        ]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setNavigationBar()
    }
    
}

