//
//  UserFriendsService.swift
//  imahima
//
//  Created by yuki goto on 2019/11/21.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import FBSDKCoreKit

class UserFriendsService {
	func getUserFriends() {
        let graphRequest : GraphRequest =
            GraphRequest(graphPath: "me/friends",
						 parameters: ["fields": "id, first_name, last_name, name, email, picture.type(large)"])
		graphRequest.start(completionHandler: { (connection, result, error) -> Void in
			if ((error) != nil) {
				print("Error: \(String(describing: error))")
			} else {
				print(result)
			}
		})
	}
}
