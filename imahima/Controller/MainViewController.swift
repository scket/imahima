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
import CoreLocation

class MainViewController: UIViewController, KolodaViewDataSource, KolodaViewDelegate {
    @IBOutlet weak var kolodaView: KolodaView!
    
    var userFriends: Array<User> = []
	var likedList: [[String: Any]] = []
    let fireStoreService = FireStoreService()
    
    var locationManager: CLLocationManager!
    
    override func viewWillAppear(_ animated: Bool) {
        let me: Me = Me.sharedInstance
        likedList = self.fireStoreService.getUsersLikedList(id: me.getId())!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Main"
        
        self.setupLocationManager()
        self.fireStoreService.setUsersCollection()
		
		// Facebookの友人情報を取得
		let userFriendsService = UserFriendsService()
		userFriends = userFriendsService.getUserFriends()
	
		// Facebookの友人のログイン時間をFireStoreから取得
		var friendsLogin: Array<UserLogin> = []
		for friend in userFriends {
            let result: UserLogin = self.fireStoreService.getUsersById(id: friend.id)
			if(!result.isEmpty()) {
				friendsLogin.append(result)
			}
		}
		
		// TODO ログイン時間でフィルターする
		// ex. 3時間以内にログインしたユーザのみ表示
		
		self.kolodaView.dataSource = self
		self.kolodaView.delegate = self
		
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //枚数
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return userFriends.count
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
		let pictureUrl = userFriends[index].pictureUrl
        imageView.image = getImageByUrl(url: pictureUrl)
		view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30.0),
            imageView.widthAnchor.constraint(equalToConstant: 300.0),
            imageView.heightAnchor.constraint(equalToConstant: 300.0),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
		
        let label = UILabel()
		label.text = userFriends[index].name
		view.addSubview(label)
		label.frame = CGRect(x:0,y:0,width:200,height:100)
        label.center = CGPoint(x: imageView.bounds.size.width/2,y: imageView.bounds.size.height - 25)
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
//		label.sizeToFit()
		
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
        userFriends = userFriends.shuffled()
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
		if (direction.rawValue == "right") {
			like(index: index)
        } else if (direction.rawValue == "left") {
            nope(index: index)
        }
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
	
	func like(index: Int) {
        var existIndex: Int? = nil
        let userId = userFriends[index].id
        let timestamp = Int(Date().timeIntervalSince1970)
        
        for (index, list) in self.likedList.enumerated() {
            if list["id"] as! String == userId {
                print("existId")
                existIndex = index
                break
            }
        }
        
        if (existIndex != nil) {
            self.likedList[existIndex!].updateValue(timestamp, forKey: "likedAt")
        } else {
            self.likedList.append([
                "id": userId,
                "likedAt": timestamp
            ])
        }
        
        print("id: \(userId), likedAt: \(timestamp)")
        print(self.likedList)
        self.fireStoreService.setUserLikedList(list: self.likedList)
	}
    
    func nope (index: Int) {
        var existIndex: Int? = nil
        for (index, list) in self.likedList.enumerated() {
            if list["id"] as! String == userFriends[index].id {
                existIndex = index
                break
            }
        }
        
        if (existIndex != nil) {
            self.likedList.remove(at: existIndex!)
            self.fireStoreService.setUserLikedList(list: self.likedList)
        }
    }
}

// 位置情報連携用のextension
extension MainViewController {
    func setupLocationManager() {
        self.locationManager = CLLocationManager()
        
        // 位置情報取得許可ダイアログの表示
        guard let locationManager = self.locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        
        // マネージャの設定
        let status = CLLocationManager.authorizationStatus()
        // ステータスごとの処理
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            // 位置情報取得を開始
            locationManager.startUpdatingLocation()
        }
    }
    
    // 位置情報が許可されていない場合にアラートを出す
    func showAlert() {
        let alertTitle = "位置情報取得が許可されていません。"
        let alertMessage = "設定アプリの「プライバシー > 位置情報サービス」から変更してください。"
        let alert: UIAlertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle:  UIAlertController.Style.alert
        )
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        // UIAlertController に Action を追加
        alert.addAction(defaultAction)
        // Alertを表示
        present(alert, animated: true, completion: nil)
    }
}

// location: delegate
extension MainViewController: CLLocationManagerDelegate {
    // 位置情報が更新された際、位置情報を格納する
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        fireStoreService.setUsersLocation(location: location!)
        print("latitude: \(String(describing: latitude)), longitude: \(String(describing: longitude))")
    }
    
    // 位置情報の取得に失敗した際に呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError err: Error) {
        print("Error(locationManager): \(err.localizedDescription)")
    }
    
}
