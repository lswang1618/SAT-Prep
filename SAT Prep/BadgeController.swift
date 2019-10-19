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
    weak var parentVC: UINavigationController?
    
    @objc func ProfileButtonTapped() {
        performSegue(withIdentifier: "signInSegue", sender: self)
    }
    
    @objc func HomeButtonTapped() {
        performSegue(withIdentifier: "homeSegue", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.popViewController(animated: true)
        tabSelector.isEnabled = false
        tabView.frame.size.width = view.frame.width
        view.addSubview(tabView)
        
        parentVC = (parent as! UINavigationController)
        parentVC?.navigationController?.navigationBar.barTintColor = UIColor(red:0.00, green:0.58, blue:0.74, alpha:1.0)
        
        model.getBadges() { [unowned self] result in
            self.badges = result
            
            weak var child = (self.childViewControllers[0] as! BadgeViewController)
            child?.fetchBadges(p: self)
            self.tabSelector.isEnabled = true
        }
        tabSelector.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "DinPro-Light", size: view.frame.height*0.018)!], for: .normal)
        tabSelector.frame.size.height = floor((UIFont(name: "DinPro-Light", size: view.frame.height*0.02)?.lineHeight)! + 2 * 10)
        tabView.frame.size.height = view.frame.height * 0.1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchView(_ sender: UISegmentedControl) {
        selectedIndex = tabSelector.selectedSegmentIndex
    }
    
    func getIndex() -> Int {
        return tabSelector.selectedSegmentIndex
    }
    
    func getBadges() -> [Badge] {
        return badges
    }
}
