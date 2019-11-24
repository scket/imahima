//
//  ViewController.swift
//  imahima
//
//  Created by yuki goto on 2019/11/03.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, LoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
		print("LoginViewController viewDidLoad()")
		let facebookLoginButton = FBLoginButton()
        // アクセス許可
        facebookLoginButton.permissions = ["public_profile", "email", "user_friends"]
        facebookLoginButton.center = self.view.center
        facebookLoginButton.delegate = self
        view.addSubview(facebookLoginButton)
	}

    // ログインコールバック
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error == nil {
            if result!.isCancelled {
                print("Login　Cancel")
            } else {
                // ユーザープロフィールを保存
				let userProfileService = UserProfileService()
				userProfileService.saveUserData()
                self.transitionToMain()
            }
        } else {
            print("Login　Error")
        }
    }

    // ログアウトコールバック
	// 実際にここに入ることはないはず
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logout")
    }
	
	func transitionToMain() {
		AppDelegate.shared.rootViewController.transitionToMain()
	}

}

