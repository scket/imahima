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
    // ユーザープロフィール
    var userProfile : NSDictionary = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
		print("LoginViewController viewDidLoad()")

        // Facebookログイン用ボタンがSDKに用意されている
        let facebookLoginButton = FBLoginButton()
        // アクセス許可
        facebookLoginButton.permissions = ["public_profile", "email"]
        facebookLoginButton.center = self.view.center
        facebookLoginButton.delegate = self
        view.addSubview(facebookLoginButton)
    }

    // ログインコールバック
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        // エラーチェック
        if error == nil {
            // ログインがユーザーにキャンセルされたかどうか
            if result!.isCancelled {
                print("Login　Cancel")

            } else {
                // ユーザープロフィールを保存
                self.saveUserData()
            }
        } else {
            print("Login　Error")
        }
    }

    // ログアウトコールバック
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logout")
    }

    // 参考：SwiftでFacebookログインと情報取得の覚書
    // https://qiita.com/noranoko/items/e1406cdd957f439db066
    // ユーザー情報を取得
    func saveUserData() {
        let graphRequest : GraphRequest =
            GraphRequest(graphPath: "me",
                         parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil) {
                print("Error: \(String(describing: error))")
            } else {
                // プロフィール情報をディクショナリに入れる
                self.userProfile = (result as! NSDictionary)

                // 名前
                let name: String = self.userProfile.object(forKey: "name") as? String ?? ""
                // メールアドレス
                let mailAddress: String = self.userProfile.object(forKey: "email") as? String ?? ""
                // アイコン画像
                let picture: NSDictionary = self.userProfile.object(forKey: "picture") as! NSDictionary
                let data: NSDictionary = picture.object(forKey: "data") as! NSDictionary
                let pictureUrl: String = data.object(forKey: "url") as! String

                // UserDefaultsに保存
                UserDefaults.standard.set(name, forKey: Const.UserDefaults.kUserNameKey)
                UserDefaults.standard.set(mailAddress, forKey: Const.UserDefaults.kMailAddressKey)
                UserDefaults.standard.set(pictureUrl, forKey: Const.UserDefaults.kPictureKey)
				
				print("name: " + name)
				print("mail address: " + mailAddress)
				print("picture: " + pictureUrl)
            }
        })
    }
	
	func transitionToMain() {
		AppDelegate.shared.rootViewController.transitionToMain()
	}
	
}

