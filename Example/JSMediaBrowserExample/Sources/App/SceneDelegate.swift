//
//  SceneDelegate.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2026/8/31.
//

import UIKit
import QMUIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = QMUINavigationController(rootViewController: HomeViewController())
        self.window?.makeKeyAndVisible()
    }

}
