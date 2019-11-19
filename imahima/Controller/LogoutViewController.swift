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
	
	func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
		print("aaa")
	}
	
	// ユーザープロフィール
	var userProfile : NSDictionary = [:]

	override func viewDidLoad() {
	super.viewDidLoad()
	print("LogoutViewController viewDidLoad()")

	// Facebookログイン用ボタンがSDKに用意されている
	let facebookLoginButton = FBLoginButton()
	// アクセス許可
	facebookLoginButton.permissions = ["public_profile", "email"]
	facebookLoginButton.center = self.view.center
	facebookLoginButton.delegate = self
	view.addSubview(facebookLoginButton)
	}
	
    // ログアウトコールバック
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logout")
    }
}
