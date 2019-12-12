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
	}

    /// アイコン画像
    @IBOutlet weak var userImageView: UIImageView! {
		didSet{
			let me: Me = Me.sharedInstance
			let pictureUrl = me.getPictureUrl()
			do {
				if let url = URL(string: pictureUrl) {
					let data = try Data(contentsOf: url)
					let image = UIImage(data: data)
					self.userImageView.image = image
				}
			} catch let e {
				print("Error : \(e.localizedDescription)")
			}
		}
    }

    /// ユーザー名
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
			let me: Me = Me.sharedInstance
			self.nameLabel.text = me.getName()
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
