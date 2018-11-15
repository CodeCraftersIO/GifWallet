//
//  AppDelegate.swift
//  GifWallet
//
//  Created by Pierluigi Cifani on 02/03/2018.
//  Copyright © 2018 Code Crafters. All rights reserved.
//

import UIKit
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    private let wireframe = Wireframe()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared().isEnabled = true

        guard NSClassFromString("XCTest") == nil else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = UIViewController()
            self.window?.makeKeyAndVisible()
            return true
        }

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = wireframe.initialViewController()
        self.window?.makeKeyAndVisible()

        return true
    }

}

import GifWalletKit

class Wireframe {

    init() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = UIColor.GifWallet.brand
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.tintColor = .white
        navigationBarAppearance.barStyle = .black
    }

    func initialViewController() -> UIViewController {
        let dataStore = DataStore()
        let presenter = GIFWalletViewController.Presenter(dataStore: dataStore)
        let vc = GIFWalletViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: vc)
        return navigationController
    }

}
