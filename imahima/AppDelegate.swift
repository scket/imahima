//
//  AppDelegate.swift
//  imahima
//
//  Created by yuki goto on 2019/11/03.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 起動時にRootViewControllerをrootViewControllerに設定する
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = RootViewController()
        window!.makeKeyAndVisible()
        return true
    }

    func application(_ application: UIApplication,open url: URL,sourceApplication: String?,annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
    }
	
}

// TODO 要理解&修正
extension AppDelegate {

	/// AppDelegateのシングルトン
	static var shared: AppDelegate {
		return UIApplication.shared.delegate as! AppDelegate
	}
	/// rootViewControllerは常にRootVC
	var rootViewController: RootViewController {
		return window!.rootViewController as! RootViewController
	}
}
