//
//  ChatRoom.swift
//  imahima
//
//  Created by Shota Takeshima on 2020/02/21.
//  Copyright © 2020 後藤祐貴. All rights reserved.
//

import Foundation

class ChatRoom {
    var id: String
    var members: Array<String>
    var messages: [[String: Any]]
    
    init(id: String, members: Array<String>, messages: [[String: Any]]) {
        self.id = id
        self.members = members
        self.messages = messages
    }
    
    // me以外のmembersのidをroom名として返す
    // [Extension]: 複数名部屋に所属する場合を考える
    func getRoomName() -> String {
        let me: Me = Me.sharedInstance
        return self.members.filter{ $0 != me.getId() }[0]
    }
}
