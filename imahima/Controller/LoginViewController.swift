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
                let dispatchGroup = DispatchGroup()
                let dispatchQueue = DispatchQueue(label: "queue")
                dispatchGroup.enter();
                dispatchQueue.async(group: dispatchGroup) {
                    self.getProfile(dg: dispatchGroup)
                }
                dispatchGroup.notify(queue: .main) {
                    self.transitionToMain()
                }
            }
        } else {
            print("Login　Error")
        }
    }
    
    func getProfile(dg: DispatchGroup) {
        _ = MyProfileService.getMyProfile() { user in
            let me: Me = Me.sharedInstance
            me.saveId(id: user.id)
            me.saveName(name: user.name)
            me.savePictureUrl(pictureUrl: user.pictureUrl)
            dg.leave()
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

