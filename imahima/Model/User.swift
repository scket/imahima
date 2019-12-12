//
//  User.swift
//  imahima
//
//  Created by yuki goto on 2019/12/12.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import Foundation

class User {
	var id: String
    var name: String
	var pictureUrl: String
	
	init(id: String, name: String, pictureUrl: String) {
		self.id = id
		self.name = name
		self.pictureUrl = pictureUrl
	}
}

class Me: NSObject {
	var me = User(id: "", name: "", pictureUrl: "")

    static let sharedInstance: Me = Me()
    private override init() {}
	
	func saveId(id: String) {
		me.id = id
	}
	func saveName(name: String) {
		me.name = name
	}
	func savePictureUrl(pictureUrl: String) {
		me.pictureUrl = pictureUrl
	}
	func getId() -> String {
		return me.id
	}
	func getName() -> String {
		return me.name
	}
	func getPictureUrl() -> String {
		return me.pictureUrl
	}
}
