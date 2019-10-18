//
//  StepZeroViewController.swift
//  Video Player
//
//  Created by Lisa Wang on 6/20/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

class StepZeroViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var emailInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.setCustomSpacing(40, after: headerLabel)
        stackView.setCustomSpacing(60, after: emailInput)
        nameInput.delegate = self
        emailInput.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameInput {
            emailInput.becomeFirstResponder()
            return false
        }
        if textField == emailInput {
            self.performSegue(withIdentifier: "returnSegue", sender: self)
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let stepOne = segue.destination as! StepOneViewController
        stepOne.name = nameInput.text
        stepOne.email = emailInput.text
    }
}
