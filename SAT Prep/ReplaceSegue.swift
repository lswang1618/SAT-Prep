//
//  ReplaceSegue.swift
//  SAT Prep
//
//  Created by Lisa Wang on 9/16/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//
import UIKit

class ReplaceSegue: UIStoryboardSegue {
    
    override func perform() {
        source.navigationController?.setViewControllers([destination], animated: true)
    }
}
