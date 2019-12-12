//
//  MyPageViewController.swift
//  imahima
//
//  Created by yuki goto on 2019/11/03.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import Foundation
import UIKit

class MyPageViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
        self.navigationItem.title = "MyPage"
        
		print("MyPageViewController viewDidLoad()")
		let userFriendsService = UserFriendsService()
		userFriendsService.getUserFriends()
	}

    /// アイコン画像
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            if let pictureUrl = UserDefaults.standard.object(forKey: Const.UserDefaults.pictureKey) {
                do {
                    let pictureUrlString = pictureUrl as! String
                    if let url = URL(string: pictureUrlString) {
                        let data = try Data(contentsOf: url)
                        let image = UIImage(data: data)
                        self.userImageView.image = image
                    }
                } catch let err {
                    print("Error : \(err.localizedDescription)")
                }
            }
        }
    }

    /// ユーザー名
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
			self.nameLabel.text = UserDefaults.standard.string(forKey: Const.UserDefaults.userNameKey)
        }
    }

    /// メールアドレス
    @IBOutlet weak var mailAddressLabel: UILabel! {
        didSet {
            self.mailAddressLabel.text = (UserDefaults.standard.object(forKey: Const.UserDefaults.mailAddressKey)) as? String
        }
    }
	
	// ログアウトボタン
	@IBOutlet weak var button: UIButton!
	@IBAction func button(_ sender: UIButton) {
		print("logout button tapped!")
		self.transitionToLogout()
	}
	
	func transitionToLogout() {
		AppDelegate.shared.rootViewController.transitionToLogout()
	}
}
