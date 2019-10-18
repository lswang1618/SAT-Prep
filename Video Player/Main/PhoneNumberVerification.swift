//
//  PhoneNumberVerification.swift
//  Video Player
//
//  Created by Lisa Wang on 10/2/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PhoneNumberVerification: UIViewController {
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var errorText: UILabel!
    
    @IBAction func verify(_ sender: UIButton) {
        if verifyButton.titleLabel!.text == "SUBMIT" {
            if textField.text != "" {
                let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: textField.text!)
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if error == nil {
                        weak var tabController = (self.storyboard?.instantiateViewController(withIdentifier: "CustomTabBarViewController") as! CustomTabBarViewController)
                        tabController?.modalPresentationStyle = .fullScreen
                        self.present(tabController!, animated: true)
                    } else {
                        self.errorText.isHidden = false
                        self.verifyButton.setTitle("VERIFY PHONE NUMBER", for: .normal)
                        self.textField.text = ""
                        self.infoText.text = "Enter your phone number"
                        self.errorText.text = "Something's not right...try again."
                        self.errorText.isHidden = false
                    }
                }
            }
        } else {
            if textField.text != "" {
                PhoneAuthProvider.provider().verifyPhoneNumber("+1" + textField.text!, uiDelegate: nil) {
                    (verificationID, error) in
                    if error == nil {
                        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                        self.textField.text = ""
                        self.errorText.isHidden = true
                        self.infoText.text = "Just texted you a verification code! Please enter it here."
                        self.verifyButton.setTitle("SUBMIT", for: .normal)
                    } else {
                        self.errorText.text = "Please enter a valid phone number."
                        self.errorText.isHidden = false
                    }
                }
            }
        }
    }
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true)
        self.parent?.dismiss(animated: false)
    }
}
