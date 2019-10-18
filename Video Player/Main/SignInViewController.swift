//
//  SignInViewController.swift
//  Video Player
//
//  Created by Lisa Wang on 10/1/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn
import FacebookLogin

class SignInViewController: UIViewController, GIDSignInDelegate, LoginButtonDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var incorrectLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var googleSignIn: GIDSignInButton!
    @IBOutlet weak var phoneSignIn: UIButton!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var border: UIView!
    
    @IBAction func signIn(_ sender: UIButton) {
        let email = emailField.text
        let password = passwordField.text
        
        if email == "" || password == "" {
            self.incorrectLabel.text = "Please enter a valid email and password."
            incorrectLabel.isHidden = false
        } else {
            Auth.auth().signIn(withEmail: email!, password: password!) { user, error in
                if error == nil {
                    self.presentHome()
                } else {
                    self.incorrectLabel.text = "The email and password combination you entered is incorrect."
                    self.incorrectLabel.isHidden = false
                }
            }
        }
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        let email = emailField.text
        if !(email?.contains("@"))! {
            incorrectLabel.text = "Please enter in a valid email address. Try your school email!"
            incorrectLabel.isHidden = false
        } else {
            Auth.auth().sendPasswordReset(withEmail: email!) { error in
                if error == nil {
                    self.incorrectLabel.text = "We've sent you a password reset email."
                } else {
                    self.incorrectLabel.text = "Hmm...we weren't able to send a password reset email. Double check the email you entered in."
                }
                self.incorrectLabel.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        let fbLogin = FBLoginButton(permissions: [.publicProfile])
        fbLogin.center.x = stackView.center.x
        fbLogin.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        fbLogin.delegate = self
        stackView.addArrangedSubview(fbLogin)
        
        stackView.setCustomSpacing(15, after: googleSignIn)
        stackView.setCustomSpacing(15, after: phoneSignIn)
        stackView.setCustomSpacing(40, after: signIn)
        stackView.setCustomSpacing(40, after: border)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
        
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if AccessToken.current != nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error == nil {
                    self.presentHome()
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                
                if error == nil {
                    self.presentHome()
                } else {
                    self.incorrectLabel.text = "Google sign in has failed. Try another method!"
                    self.incorrectLabel.isHidden = false
                }
            }
        } else {
            self.incorrectLabel.text = "Google sign in has failed. Try another method!"
            self.incorrectLabel.isHidden = false
        }
    }
    
    func presentHome() {
        weak var tabController = (self.storyboard?.instantiateViewController(withIdentifier: "CustomTabBarViewController") as! CustomTabBarViewController)
        tabController?.modalPresentationStyle = .fullScreen
        self.present(tabController!, animated: true)
    }
}
