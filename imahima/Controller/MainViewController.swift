//
//  MainViewController.swift
//  imahima
//
//  Created by Shota Takeshima on 2019/11/21.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import UIKit
import Koloda
import Firebase
import FirebaseFirestore

class MainViewController: UIViewController, KolodaViewDataSource, KolodaViewDelegate {
    @IBOutlet weak var kolodaView: KolodaView!
    
    var imageNameArray = ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg", "7.jpg", "8.jpg", "9.jpg", "10.jpg", ]
    
    var userArray: Array<User> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Main"
		
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")
        dispatchGroup.enter();
        dispatchQueue.async(group: dispatchGroup) {
            self.getUsers(dg: dispatchGroup)
        }
        
//        dispatchQueue.async(group: dispatchGroup) {
//            self.getUserFriends(dg: dispatchGroup)
//        }
        
        dispatchGroup.notify(queue: .main) {
            self.addUsersCollection()
        }
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
    }
    
    func getUsers (dg: DispatchGroup) {
        let dataStore = Firestore.firestore()
        let me: Me = Me.sharedInstance
        let users = dataStore.collection("users")
        let query = users.whereField("id", isEqualTo: me.getId())
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
                if querySnapshot!.documents.count == 1 {
                    print("only one user data exists. ok")
                } else {
                    print("no data exists")
                }
            }
            dg.leave()
        }
    }
    
    func getUserFriends (dg: DispatchGroup) {
        let userFriendsService = UserFriendsService()
        userFriendsService.getUserFriends() { users in
            for user in users {
                self.userArray.append(User(id: user.id, name: user.name, pictureUrl: user.pictureUrl))
            }
            dg.leave()
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //枚数
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return imageNameArray.count
    }
    
    //ドラッグのスピード
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }

    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = UIView()
        view.frame = CGRect(x:0, y: 0, width: 200, height: 200)
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        
        // ラベルを表示する.
        let label = UILabel()
        label.text = imageNameArray[index]
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
        
        return view
    }
    
    // カードを全て消費した時に呼ばれる
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        print("Finish cards.")
        //シャッフル
        imageNameArray = imageNameArray.shuffled()
        //リスタート
        koloda.resetCurrentCardIndex()
    }
    
    // カードをタップした時に呼ばれる
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
    }

    // ドラッグをやめた時に呼ばれる
    func kolodaDidResetCard(_ koloda: KolodaView) {
        print("reset")
    }

    // ドラッグ中に呼ばれる
    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
        print(index, "drag")
        return true
    }

    // dragの方向などを設定
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        print(index, direction)
    }

    // Nopeを押した場合はleftへスワイプ
    @IBAction func cardGoToNope() {
        kolodaView.swipe(.left)
    }

    // Likeを押した場合は右へスワイプ
    @IBAction func cardGoToLike() {
        kolodaView.swipe(.right)
    }
}
