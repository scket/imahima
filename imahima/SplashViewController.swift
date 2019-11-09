//
//  SplashViewController.swift
//  imahima
//
//  Created by yuki goto on 2019/11/07.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import UIKit
import FBSDKLoginKit

final class SplashViewController: UIViewController {
	// 処理中を示すインジケーター
	private lazy var activityIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
		indicator.frame = view.bounds
        indicator.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
		return indicator
	}()

	// 処理中に表示させておくスプラッシュ画像
	// LaunchScreenでも同じ画像を指定
	private lazy var splashImage: UIImageView = {
		let imageView = UIImageView(
			image: UIImage(named: "SplashImage")
		)
		imageView.contentMode = .scaleAspectFill
		imageView.frame = view.frame
		return imageView
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		print("SplashViewController viewDidLoad()")

        view.addSubview(splashImage)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
		
		// FBログインで分岐
		if checkloginFacebook() {
			// ログイン済みであればホーム画面へ遷移
			print("Already logged in")
			AppDelegate.shared.rootViewController.transitionToMain()
		} else {
			// ログイン済みでなければログイン画面へ遷移
			print("Not logged in")
			AppDelegate.shared.rootViewController.transitionToLogin()
		}
    }
	
    /// ログイン済みかチェック
    func checkloginFacebook() -> Bool {
        if let _ = AccessToken.current {
            return true
        } else {
            return false
        }
    }
}
