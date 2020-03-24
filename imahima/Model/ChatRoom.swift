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
    
    init(id: String, members: Array<String>) {
        self.id = id
        self.members = members
    }
    
    // me以外のmembersのidを返す
    // [Extension]: 複数名部屋に所属する場合を考える
    func getOtherMemberId() -> String {
        let me: Me = Me.sharedInstance
        return self.members.filter{ $0 != me.getId() }[0]
    }
}
