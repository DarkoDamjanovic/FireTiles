//
//  AppDelegate.swift
//  FireTiles
//
//  Created by Darko Damjanovic on 04.03.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var dependencyContainer: DependencyContainerProtocol = DependencyContainer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.launchUI()
        return true
    }

    /// Launch the UI removeObserver programatically.
    /// This gives us the chance to inject the root dependencies.
    private func launchUI() {
        let builder = MapBuilder(dependencyContainer: self.dependencyContainer)
        let view = builder.build()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = view
        self.window?.makeKeyAndVisible()
    }
}

