//
//  MyProfileService.swift
//  imahima
//
//  Created by yuki goto on 2019/12/12.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class MyProfileService {
	
	init(){}
	
    class func getMyProfile() {
        let graphRequest : GraphRequest =
            GraphRequest(graphPath: "me",
                         parameters: ["fields": "id,name, first_name, last_name, picture.type(large)"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil) {
                print("Error: \(String(describing: error))")
            } else {
                // APIのレスポンスをuserProfileに入れる
                let myProfile = (result as! NSDictionary)
				
				let id: String = myProfile.object(forKey: "id") as? String ?? ""
                let name: String = myProfile.object(forKey: "name") as? String ?? ""
                let picture: NSDictionary = myProfile.object(forKey: "picture") as! NSDictionary
                let data: NSDictionary = picture.object(forKey: "data") as! NSDictionary
                let pictureUrl: String = data.object(forKey: "url") as! String

				let me: Me = Me.sharedInstance
				me.saveId(id: id)
				me.saveName(name: name)
				me.savePictureUrl(pictureUrl: pictureUrl)
            }
        })
    }
}
