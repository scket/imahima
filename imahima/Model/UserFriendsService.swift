//
//  UserFriendsService.swift
//  imahima
//
//  Created by yuki goto on 2019/11/21.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import FBSDKCoreKit

/*
Facebook APIの me/friends エンドポイントの結果を取得するクラス
リクエストを行うライブラリは非同期処理だが，この結果を後続処理で使うため同期処理にした
*/
class UserFriendsService {
	func getUserFriends() -> Array<User> {
		var keepAlive = true
		var userFriends: Array<User> = []
        let graphRequest : GraphRequest =
            GraphRequest(graphPath: "me/friends",
						 parameters: ["fields": "id, first_name, last_name, name, picture.type(large)"])
		graphRequest.start(completionHandler: { (connection, result, error) -> Void in
			if ((error) != nil) {
				print("Error: \(String(describing: error))")
				return
			} else {
				let root = (result as! NSDictionary)
				let friends: NSArray = root.object(forKey: "data") as! NSArray
				for friend in friends {
					let friendDic = friend as! NSDictionary
					let id: String = friendDic.object(forKey: "id") as? String ?? ""
					let name: String = friendDic.object(forKey: "name") as? String ?? ""
					let picture: NSDictionary = friendDic.object(forKey: "picture") as! NSDictionary
					let data: NSDictionary = picture.object(forKey: "data") as! NSDictionary
					let pictureUrl: String = data.object(forKey: "url") as! String
					userFriends.append(User(id: id, name: name, pictureUrl: pictureUrl))
				}
				keepAlive = false
			}
		})
		let runLoop = RunLoop.current
		while keepAlive && runLoop.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 0.1)) {}
		return userFriends
	}

}
