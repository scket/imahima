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
					print("no data exists")
				}
			}
			keepAlive = false
		}
		let runLoop = RunLoop.current
		while keepAlive && runLoop.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 0.01)) {}
		return userLogin
	}
	
    func addUsersCollection () {
        let dataStore = Firestore.firestore()
        let me: Me = Me.sharedInstance
        let timeStamp = Int(Date().timeIntervalSince1970)
        dataStore.collection("users").addDocument(data: [
            "id": me.getId(),
            "time": timeStamp
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
    }
}
