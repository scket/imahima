//
//  TabBarController.swift
//  imahima
//
//  Created by Shota Takeshima on 2019/11/21.
//  Copyright © 2019 後藤祐貴. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blue

        let names = ["MyPage", "Main", "ChatRoom"]
        
        // 手続き型の言語っぽく書いてみた
        var viewControllers = [UIViewController]()
        for name in names {
            let storyboard = UIStoryboard(name: name, bundle: nil)
            if let viewController = storyboard.instantiateInitialViewController() {
                viewControllers.append(viewController)
            }
        }
        
        setViewControllers(viewControllers, animated: false)
    }
}
