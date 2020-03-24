//
//  FireStoreService.swift
//  imahima
//
//  Created by yuki goto on 2020/01/20.
//  Copyright © 2020 後藤祐貴. All rights reserved.
//

import Firebase
import FirebaseFirestore

/*
FireStoreのコレクション操作を提供するクラス
*/
class FireStoreService {
    
    var snapshotLisener: ListenerRegistration?
	
	/*
	Facebook IDからそのIDのログイン時間をFireStoreから取得する
	Mainの表示で必要となるため同期処理にしている
	*/
	func getUsersById(id: String) -> UserLogin {
		var keepAlive = true
		var userLogin: UserLogin = UserLogin(id: "", login: 0)
		let dataStore = Firestore.firestore()
		let users = dataStore.collection("users")
		let query = users.whereField("id", isEqualTo: id)
		
		query.getDocuments() { (querySnapshot, err) in
			if let err = err {
				print("Error getting documents: \(err)")
			} else {
				if querySnapshot!.documents.count == 1 {
					for document in querySnapshot!.documents {
						print("\(document.documentID) => \(document.data())")
						let doc = document.data() as NSDictionary
						let id: String = doc.object(forKey: "id") as? String ?? ""
						let login: Int = doc.object(forKey: "time") as? Int ?? 0
                        userLogin = UserLogin(id: id, login: login)
					}
				} else {
					print("getUsersById: no data exists")
				}
			}
			keepAlive = false
		}
		let runLoop = RunLoop.current
		while keepAlive && runLoop.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 0.01)) {}
		return userLogin
	}
	
	/**
	Facebook IDをkeyとしてログイン時間の情報を作成・更新する
	*/
    func setUsersCollection () {
        let dataStore = Firestore.firestore()
        let me: Me = Me.sharedInstance
        let timeStamp = Int(Date().timeIntervalSince1970)
		dataStore.collection("users").document(me.getId()).setData([
            "id": me.getId(),
            "time": timeStamp
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("setUsersCollection: Document added")
            }
        }
    }
    
    /*
     Likeをしたユーザーのリストを取得する
     存在しない場合は空配列を返す
     */
    func getUsersLikedList(id: String) -> [[String: Any]]? {
        var keepAlive = true
        var likedList: [[String: Any]] = []
        let dataStore = Firestore.firestore()
        let matching = dataStore.collection("matching")
        
        matching.document(id).getDocument{(snap, error) in
            if let document = snap, snap!.exists {
                likedList = document.get("likedList") as! [[String : Any]]
            } else {
                print("getUsersLikedList: Document does not exist")
            }
            keepAlive = false
        }
        
        let runLoop = RunLoop.current
        while keepAlive && runLoop.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 0.01)) {}
        return likedList
    }
	
    /*
     Likeをしたユーザーのリストを作成・更新する
     */
    func setUserLikedList (list: [[String: Any]]) {
        let me: Me = Me.sharedInstance
		let dataStore = Firestore.firestore()
        dataStore.collection("matching").document(me.getId()).setData([
            "likedList": list
        ], merge: true) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("setUserLikedList: Document added")
            }
        }
	}
    
    /*
     meが所属しているチャットルームのリストを取得する
    */
    func getChatRooms() -> Array<ChatRoom>! {
        print("call getChatRooms")
        
        var keepAlive = true
        
        let me: Me = Me.sharedInstance
        var chatrooms: Array<ChatRoom> = []
        
        let dataStore = Firestore.firestore()
        let resourse = dataStore.collection("chatrooms")
        let query = resourse.whereField("members", arrayContains: me.getId())
        
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if querySnapshot!.documents.count != 0 {
                    for document in querySnapshot!.documents {
                        let doc = document.data() as NSDictionary
                        let id: String = document.documentID
                        let members: Array<String> = doc.object(forKey: "members") as? Array<String> ?? []
                        chatrooms.append(ChatRoom(id: id, members: members))
                    }
                } else {
                    print("getChatRooms: no data exists")
                }
            }
            keepAlive = false
        }
        let runLoop = RunLoop.current
        while keepAlive && runLoop.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 0.01)) {}
        return chatrooms
    }
    
    /*
     チャットルームIDからメッセージ一覧を取り出す
    */
    func getMessageData(id: String, completion: @escaping (MessageData) -> Void) {
        print("call getMessageData")
        
        let dataStore = Firestore.firestore()
        let resourse = dataStore.collection("chatrooms").document(id).collection("messages").order(by: "createdAt", descending: false)
        
        self.snapshotLisener = resourse.addSnapshotListener { (querySnapshot, err) in
           if let err = err {
                print("Error getting documents: \(err)")
            } else {
               querySnapshot?.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                       let doc = diff.document.data() as NSDictionary
                       let from: String = doc.object(forKey: "from") as! String
                       let createdAt: String = doc.object(forKey: "createdAt") as! String
                       let message: String = doc.object(forKey: "message") as! String
                       completion(MessageData(from: from, createdAt: createdAt, message: message))
                    }
                }
            }
        }
    }
    
    /*
     チャットルームIDに応じたメッセージのクエリを返す
    */
    func getMessageDataResource(id: String) -> Query {
        return Firestore.firestore().collection("chatrooms").document(id).collection("messages").order(by: "createdAt", descending: false)
    }
    
    /*
     メッセージを追加する
    */
    func setMessageData(id: String, messageData: MessageData) {
        print("call setMessageData")
        
        let dataStore = Firestore.firestore()
        let resourse = dataStore.collection("chatrooms").document(id).collection("messages")
        
        resourse.addDocument(data: [
            "from": messageData.from,
            "createdAt": messageData.createdAt,
            "message": messageData.message,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                
            } else {
                print("setMessageData: Document added")
            }
        }
    }
    
    /*
        起動中のリスナを削除する
    */
    func removeSnapshotListenr () {
        print("call removeSnapshotListenr")
        
        if let w = self.snapshotLisener { w.remove() }
    }
}
