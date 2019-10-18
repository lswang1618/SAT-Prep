//
//  StepTwoViewController.swift
//  Video Player
//
//  Created by Lisa Wang on 6/20/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

class StepTwoViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var agreementLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    
    var name = ""
    var email = ""
    var selectedTag = "All"
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.setCustomSpacing(60, after: agreementLabel)
        stackView.setCustomSpacing(40, after: agreementLabel)
        
        if selectedTag == "All" {
            thanksLabel.text = "Cool, we'll help figure out where you need to practice."
        } else {
            thanksLabel.text = "Great, we'll make sure you get a lot of " + selectedTag + " practice in."
        }
    }
    @IBAction func agree(_ sender: UIButton) {
        let userDefaults = UserDefaults.standard
        userDefaults.set("2.0", forKey: "currentVersion")
        self.performSegue(withIdentifier: "homeSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! CustomTabBarViewController
        let homeVC = destination.viewControllers![0] as! HomeController
        homeVC.name = name
        homeVC.email = email
        homeVC.targetSubject = selectedTag
    }
}
