//
//  messageData.swift
//  imahima
//
//  fireStoreで管理しているmessage用のモデル
//
//  Created by Shota Takeshima on 2020/03/12.
//  Copyright © 2020 後藤祐貴. All rights reserved.
//

import Foundation

class MessageData {
    var from: String
    var createdAt: String
    var message: String
    
    init(from: String, createdAt: String, message: String) {
        self.from = from
        self.createdAt = createdAt
        self.message = message
    }
}
