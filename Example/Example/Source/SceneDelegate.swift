//
//  SceneDelegate.swift
//  Example
//
//  Created by Daniil Subbotin on 29.07.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        scene.windows.first?.tintColor = .tint
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.largeTitle(),
            NSAttributedString.Key.foregroundColor: UIColor.textSecondary
        ]
        appearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.header(),
            NSAttributedString.Key.foregroundColor: UIColor.textSecondary
        ]
        UINavigationBar.appearance().standardAppearance = appearance
    }

}

