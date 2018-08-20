//
//  AuthChoiceController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 7/18/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import Foundation
import FirebaseUI

class AuthChoiceController: FUIAuthPickerViewController {
    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        let signInLabel = UILabel()
        signInLabel.translatesAutoresizingMaskIntoConstraints = false
        signInLabel.numberOfLines = 0
        signInLabel.text = "sign in"
        signInLabel.font = UIFont(name: "Gill Sans", size: 56)
        signInLabel.textColor = UIColor(red:0.00, green:0.58, blue:0.74, alpha:1.0)
        view.addSubview(signInLabel)
        let c_H = NSLayoutConstraint(item: signInLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.8, constant: 0)
        let c_V = NSLayoutConstraint(item: signInLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(c_H)
        view.addConstraint(c_V)
        
        self.navigationItem.titleView = UILabel()
    }
}
