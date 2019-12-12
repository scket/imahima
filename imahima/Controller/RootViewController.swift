//
//  RootViewController.swift
//  imahima
//
//  Created by yuki goto on 2019/11/07.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {
    // 現在表示しているViewController
    private var current: UIViewController
	
    init() {
        // 起動時最初の画面はSplashViewControllerを設定
        current = SplashViewController()
        super.init(nibName: nil, bundle: nil)
    }
	
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		current = SplashViewController()
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
		print("RootViewController viewDidLoad(). Cuurent is "
			+ String(describing: type(of: current)))

    }
	
    // RootVCの子VCを入れ替える＝ルートの画面を切り替える
    func transition(to vc: UIViewController) {
		print("Current view controller is " + String(describing: type(of: current)))
        // 新しい子VCを追加
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        // 現在のVCを削除する準備
        current.willMove(toParent: nil)
        // Superviewから現在のViewを削除
        current.view.removeFromSuperview()
        // RootVCから現在のVCを削除
        current.removeFromParent()
        // 現在のVCを更新
        current = vc
		
		print("Next view controller is " + String(describing: type(of: current)))
    }
	
    // ホーム画面への遷移
    func transitionToMain() {
        // 切り替えたい先のViewControllerを用意
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        transition(to: vc)
    }
	
    // ログイン画面への遷移
    func transitionToLogin() {
        // 切り替えたい先のViewControllerを用意
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!
		transition(to: vc)
    }
	
    // ログアウト画面への遷移
    func transitionToLogout() {
        // 切り替えたい先のViewControllerを用意
        let vc = UIStoryboard(name: "Logout", bundle: nil).instantiateInitialViewController()!
		transition(to: vc)
    }
    
    // チャット画面への遷移
    func transitionToChat() {
        // 切り替えたい先のViewControllerを用意
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateInitialViewController()!
        transition(to: vc)
    }
    
    private func replaceCurrent(for new: UIViewController) {
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = new
    }
}
