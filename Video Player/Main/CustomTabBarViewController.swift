//
//  CustomTabBarViewController.swift
//  Video Player
//
//  Created by Lisa Wang on 6/19/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

class CustomTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        for item in self.tabBar.items! as [UITabBarItem] {
            item.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
            item.title = nil
        }
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    }
}
