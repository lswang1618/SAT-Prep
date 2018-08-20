//
//  SignInController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 7/18/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseUI

class SignInController: UIViewController, FUIAuthDelegate {
    
    var profileURL: String = ""
    var name: String = ""
    var days: Array<Int> = []
    var time: Int = 0
    var user = Auth.auth().currentUser
    
    private lazy var accountController: AccountViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
        
        // Add View Controller as Child View Controller
        self.add(viewController: viewController)
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let parent = self.parent as! UINavigationController
        parent.navigationController?.navigationBar.barTintColor = UIColor(red:0.00, green:0.58, blue:0.74, alpha:1.0)
        
        if (user != nil) {
            if (user!.isAnonymous) {
                
                let authUI = FUIAuth.defaultAuthUI()
                // You need to adopt a FUIAuthDelegate protocol to receive callback
                authUI?.delegate = self
                
                let providers: [FUIAuthProvider] = [
                    FUIGoogleAuth(),
                    FUIFacebookAuth(),
                    FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
                    ]
                authUI?.providers = providers
                //authUI?.shouldAutoUpgradeAnonymousUsers = true
        
                let authViewController = authUI?.authViewController()
                present(authViewController!, animated: true, completion: nil)
            } else {
                isLoggedIn()
            }
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        let x = Auth.auth().currentUser
        if (x?.isAnonymous)! || error != nil {
            self.performSegue(withIdentifier: "logoutSegue", sender: nil)
        } else {
            let data = Auth.auth().currentUser?.providerData[0]
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = data?.displayName
            changeRequest?.photoURL = data?.photoURL
            changeRequest?.commitChanges { (error) in
            }
            self.user = Auth.auth().currentUser
            isLoggedIn()
        }
        
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        
        return AuthChoiceController(authUI: authUI)
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func isLoggedIn() {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.isPersistenceEnabled = true
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        let model = Model()
        
        model.getUser() { eUser in
            
            if self.user != nil {
                var changed = false
                if eUser.name == "" && self.user?.displayName != nil{
                    self.name = (self.user?.displayName)!
                    changed = true
                    
                } else {
                    self.name = eUser.name
                }
                if eUser.profileImage == "" && self.user?.photoURL != nil{
                    self.profileURL = (self.user?.photoURL?.absoluteString)!
                    changed = true
                } else {
                    self.profileURL = eUser.profileImage
                }
                if changed {
                    db.collection("users").document((self.user?.uid)!).updateData([
                        "name": self.name,
                        "profileImage": self.profileURL
                    ])
                }
            }
            
            self.days = eUser.days
            self.time = eUser.time
            self.accountController.days = self.days
            
            self.accountController.name = self.name
            self.accountController.profileURL = self.profileURL
            self.accountController.time = self.time
            self.accountController.uid = (self.user?.uid)!
            
            self.add(viewController: self.accountController)
        }
        
    }
    
    func add(viewController: UIViewController){
        addChildViewController(viewController)
        
        view.addSubview(viewController.view)
        
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParentViewController: self)
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logoutSegue", sender: nil)
        } catch {
            
        }
    }
}
