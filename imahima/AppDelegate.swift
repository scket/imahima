//
//  AppDelegate.swift
//  imahima
//
//  Created by yuki goto on 2019/11/03.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import UIKit
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
		
        print("appdeligate didFinishLaunchingWithOptions")
        // 起動時にRootViewControllerをrootViewControllerに設定する
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = RootViewController()
        window!.makeKeyAndVisible()
        return true
    }
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
		if ApplicationDelegate.shared.application(app, open: url, options: options) {
			return true
		}
		return false
	}

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        AppEvents.activateApp()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
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
