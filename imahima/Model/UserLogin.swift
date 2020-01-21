//
//  UserLogin.swift
//  imahima
//
//  Created by yuki goto on 2020/01/20.
//  Copyright © 2020 後藤祐貴. All rights reserved.
//

import Foundation

class UserLogin {
	var id: String
    var login: Int
	
	init(id: String, login: Int) {
		self.id = id
		self.login = login
	}
	
	func isEmpty() -> Bool {
		if(self.id == "") {
			return true
		}
		return false
	}
}
