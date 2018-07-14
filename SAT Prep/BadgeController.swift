//
//  BadgeController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 6/9/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import UIKit

class BadgeController: UITabBarController {
    
    @IBOutlet var tabView: UIView!
    @IBOutlet weak var tabSelector: UISegmentedControl!
    var index = 0
    
    let model = Model()
    var badges = [Badge]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabView.frame.size.width = self.view.frame.width
        self.view.addSubview(tabView)
        
        model.getBadges() {result in
            self.badges = result
            
            let child = self.childViewControllers[0] as! BadgeViewController
            child.fetchBadges(p: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchView(_ sender: UISegmentedControl) {
        self.selectedIndex = tabSelector.selectedSegmentIndex
    }
    
    func getIndex() -> Int {
        return tabSelector.selectedSegmentIndex
    }
    
    func getBadges() -> [Badge] {
        return self.badges
    }
}
