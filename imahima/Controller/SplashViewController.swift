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
		
		/// ログイン済みかチェック
		if (self.checkLoginFacebook()) {
				print("Already Logged in. Go MainVeiwController.")
                let dispatchGroup = DispatchGroup()
                let dispatchQueue = DispatchQueue(label: "queue")
                dispatchGroup.enter();
                dispatchQueue.async(group: dispatchGroup) {
                    self.getProfile(dg: dispatchGroup)
                }
                dispatchGroup.notify(queue: .main) {
                    self.transitionToMain()
                }
		} else {
				print("Not Logged in.")
				self.transitionToLogin()
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
	
    /// ログイン済みかチェック
    func checkLoginFacebook() -> Bool {
        if let _ = AccessToken.current {
            return true
        } else {
			AccessToken.initialize()
            return false
        }
    }
	
	func transitionToMain() {
		AppDelegate.shared.rootViewController.transitionToMain()
	}
	
	func transitionToLogin() {
		AppDelegate.shared.rootViewController.transitionToLogin()
	}
}
