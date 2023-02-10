//
//  AppDelegate.swift
//  Example
//
//  Created by leven on 2023/2/7.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        window?.frame = UIScreen.main.bounds
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }



}

