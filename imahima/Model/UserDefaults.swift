//
//  UserDefaults.swift
//  imahima
//
//  Created by yuki goto on 2019/11/03.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import Foundation

// UserDefaultsのkey管理
struct Const {
    struct UserDefaults {
		/// ID
		static let idKey: String = "id"
        /// ユーザー名
        static let userNameKey: String =  "userName"
        /// メールアドレス
        static let mailAddressKey: String = "mailAddress"
        /// アイコン画像
        static let pictureKey: String =  "picture"
    }
}
