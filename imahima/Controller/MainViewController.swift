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
    
    var userArray: Array<User> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Main"
		
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")
        dispatchGroup.enter();
//        dispatchQueue.async(group: dispatchGroup) {
//            self.getUsers(dg: dispatchGroup)
//        }
        
        dispatchQueue.async(group: dispatchGroup) {
            self.getUserFriends(dg: dispatchGroup)
        }
        
        dispatchGroup.notify(queue: .main) {
//            self.addUsersCollection()
			self.kolodaView.dataSource = self
			self.kolodaView.delegate = self
        }
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
        return userArray.count
    }
    
    //ドラッグのスピード
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let screenWidth = self.view.bounds.width
        let screenHeight = self.view.bounds.height
		
        let view = UIView()
        view.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        
		
        let imageView = UIImageView(frame: koloda.bounds)
        imageView.contentMode = .scaleAspectFit
		let pictureUrl = userArray[index].pictureUrl
        imageView.image = getImageByUrl(url: pictureUrl)
		
		view.addSubview(imageView)
		
        let label = UILabel()
		label.text = userArray[index].name
		view.addSubview(label)
		label.frame = CGRect(x:0,y:0,width:200,height:50)
		label.center = CGPoint(x:screenWidth/2,y:screenHeight/2 - 25)
		label.textAlignment = NSTextAlignment.center
		label.sizeToFit()
		
        return view
    }
	
	func getImageByUrl(url: String) -> UIImage{
		let url = URL(string: url)
		do {
			let data = try Data(contentsOf: url!)
			return UIImage(data: data)!
		} catch let err {
			print("Error : \(err.localizedDescription)")
		}
		return UIImage()
	}
    
    // カードを全て消費した時に呼ばれる
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        print("Finish cards.")
        //シャッフル
        userArray = userArray.shuffled()
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
