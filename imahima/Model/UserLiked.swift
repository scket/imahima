//
//  UserLiked.swift
//  imahima
//
//  Created by yuki goto on 2020/01/23.
//  Copyright © 2020 後藤祐貴. All rights reserved.
//

import Foundation

class UserLiked {
	var id: String
    var likedAt: String
	
	init(id: String, likedAt: String) {
		self.id = id
		self.likedAt = likedAt
	}
	
	func isEmpty() -> Bool {
		if(self.id == "") {
			return true
		}
		return false
	}
}
