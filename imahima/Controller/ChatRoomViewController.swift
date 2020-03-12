//
//  ChatRoomViewController.swift
//  imahima
//
//  Created by Shota Takeshima on 2019/11/21.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import UIKit

class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var chatRoomList: Array<ChatRoom> = []
    var userFriends: Array<User> = []
    let fireStoreService = FireStoreService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "ChatRoom"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Facebookの友人情報を取得
        let userFriendsService = UserFriendsService()
        userFriends = userFriendsService.getUserFriends()
        
        self.chatRoomList = self.fireStoreService.getChatRooms()!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let userId: String = chatRoomList[indexPath.row].getOtherMemberId()
        let roomName: String = self.userFriends.filter{ $0.id == userId }[0].name
        
        cell.textLabel!.text = roomName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        let userId: String = chatRoomList[indexPath.row].getOtherMemberId()
        let partner: User = self.userFriends.filter{ $0.id == userId }[0]
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)//遷移先のStoryboardを設定
        let nextView = storyboard.instantiateViewController(withIdentifier: "Chat") as! ChatViewController//遷移先のViewControllerを設定
        
        nextView.roomId = chatRoomList[indexPath.row].id
        nextView.partner = partner
        
        self.navigationController?.pushViewController(nextView, animated: true)//遷移する
    }
    
    func transitionToChat() {
        AppDelegate.shared.rootViewController.transitionToChat()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
