//
//  AppDelegate.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/10/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let userManager = UserManager()
    private lazy var mediaManager = MediaManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        let countryDefaults: [String: String] = ["countryName": "United States of America", "countryCode": "US"]
        UserDefaults.standard.register(defaults: countryDefaults)

        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().tintColor = UIColor(named: "offYellow")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)]

        UITabBar.appearance().barTintColor = .black
        UITabBar.appearance().tintColor = UIColor(named: "offYellow")

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = #colorLiteral(red: 0.1940585673, green: 0.2092419863, blue: 0.2196866274, alpha: 1)
        window?.makeKeyAndVisible()

        window?.rootViewController = RootTabBarController(userManager: userManager, mediaManager: mediaManager)

        return true
    }
}

