//
//  LogOut.swift
//  Video Player
//
//  Created by Lisa Wang on 10/2/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

class LogOut: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var invalidLabel: UILabel!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.setCustomSpacing(60, after: passwordField)
        
        emailField.text = user?.email
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        if !emailField.text!.contains("@") || passwordField.text == "" {
            invalidLabel.text = "Please enter a valid email and password to save."
            invalidLabel.isHidden = false
            stackView.setCustomSpacing(25, after: passwordField)
            stackView.setCustomSpacing(60, after: invalidLabel)
        } else if passwordField.text!.count < 7 {
            invalidLabel.text = "Please enter a password with at least 7 characters."
            invalidLabel.isHidden = false
            stackView.setCustomSpacing(25, after: passwordField)
            stackView.setCustomSpacing(60, after: invalidLabel)
        } else {
            let email = emailField.text!
            
            let model = Model()
            model.updateUserEmail(email: email)
            
            let password = passwordField.text!
            let anonUser = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            anonUser!.link(with: credential) { (authResult, error) in
                if error == nil {
                    let _ = try? Firebase.Auth.auth().signOut()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let accountChoiceController = storyboard.instantiateViewController(withIdentifier: "AccountChoice") as? UIViewController else {
                        return
                    }
                    accountChoiceController.modalPresentationStyle = .fullScreen
                    self.present(accountChoiceController, animated: true)
                }
            }
            //}
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
