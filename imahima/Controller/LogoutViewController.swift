//
//  LogoutViewController.swift
//  imahima
//
//  Created by yuki goto on 2019/11/19.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LogoutViewController: UIViewController, LoginButtonDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		print("LogoutViewController viewDidLoad()")

		let facebookLoginButton = FBLoginButton()
		facebookLoginButton.permissions = ["public_profile", "email"]
		facebookLoginButton.center = self.view.center
		facebookLoginButton.delegate = self
		view.addSubview(facebookLoginButton)
	}
	
    // ログアウトコールバック
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
		self.transitionToLogin()
    }
	
	// ログアウトエラーコールバック
	func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
		self.transitionToLogin()
	}
	
	func transitionToLogin() {
		AppDelegate.shared.rootViewController.transitionToLogin()
	}

}
