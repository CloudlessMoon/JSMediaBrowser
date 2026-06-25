//
//  AppDelegate.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2024/12/30.
//

import UIKit
import QMUIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.configDebug()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = QMUINavigationController(rootViewController: HomeViewController())
        self.window?.makeKeyAndVisible()
        return true
    }

}
