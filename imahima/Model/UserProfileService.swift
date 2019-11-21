//
//  UserProfileService.swift
//  imahima
//
//  Created by yuki goto on 2019/11/20.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import FBSDKLoginKit

// FBでUserProfileAPIをcallし結果をUserDefaulsにsetする
class UserProfileService {
	
    func saveUserData() {
        let graphRequest : GraphRequest =
            GraphRequest(graphPath: "me",
                         parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil) {
                print("Error: \(String(describing: error))")
            } else {
                // APIのレスポンスをuserProfileに入れる
                let userProfile = (result as! NSDictionary)
				
				let id: String = userProfile.object(forKey: "id") as? String ?? ""
                let name: String = userProfile.object(forKey: "name") as? String ?? ""
                let mailAddress: String = userProfile.object(forKey: "email") as? String ?? ""
                let picture: NSDictionary = userProfile.object(forKey: "picture") as! NSDictionary
                let data: NSDictionary = picture.object(forKey: "data") as! NSDictionary
                let pictureUrl: String = data.object(forKey: "url") as! String

                // UserDefaultsに保存
				UserDefaults.standard.set(id, forKey: Const.UserDefaults.idKey)
                UserDefaults.standard.set(name, forKey: Const.UserDefaults.userNameKey)
                UserDefaults.standard.set(mailAddress, forKey: Const.UserDefaults.mailAddressKey)
                UserDefaults.standard.set(pictureUrl, forKey: Const.UserDefaults.pictureKey)
            }
        })
    }
}
