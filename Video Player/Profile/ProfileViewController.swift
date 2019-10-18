//
//  ProfileViewController.swift
//  Video Player
//
//  Created by Lisa Wang on 6/20/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FacebookLogin

class ProfileViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var hoursPracticed: UILabel!
    @IBOutlet weak var sectionsCompleted: UILabel!
    @IBOutlet weak var readingProgress: UILabel!
    @IBOutlet weak var readingProgressBar: UIProgressView!
    @IBOutlet weak var mathProgress: UILabel!
    @IBOutlet weak var mathProgressBar: UIProgressView!
    @IBOutlet weak var writingProgress: UILabel!
    @IBOutlet weak var writingProgressBar: UIProgressView!
    @IBOutlet weak var readingLabel: UILabel!
    @IBOutlet weak var mathLabel: UILabel!
    @IBOutlet weak var writingLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    var countDict = [String: Int]()
    var user: User? {
        didSet {
            updateName()
        }
    }
    
    var screenHeight = CGFloat(0.0)
    
    override func viewDidLoad() {
        let transform = CGAffineTransform.init(scaleX: 1.0, y: 3.0)
        readingProgressBar.transform = transform
        writingProgressBar.transform = transform
        mathProgressBar.transform = transform
        settingsButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let model = Model()
        model.getUser() { user in
            self.user = user
            let minutesPracticedString = NSMutableAttributedString()
            let lightAttrs = [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "SFProText-Light", size: self.screenHeight * 0.0175)!]
            let boldAttrs = [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "SFProText-Medium", size: self.screenHeight * 0.03)!]
            
            minutesPracticedString.append(NSMutableAttributedString(string: String(Int(user.minutesPracticed)), attributes:boldAttrs))
            minutesPracticedString.append(NSMutableAttributedString(string: "\nminutes practiced", attributes: lightAttrs))
            self.hoursPracticed.attributedText = minutesPracticedString
            
            let tagsCompletedString = NSMutableAttributedString()
            tagsCompletedString.append(NSMutableAttributedString(string: String(Int(user.tagsCompleted)), attributes: boldAttrs))
            tagsCompletedString.append(NSMutableAttributedString(string: "\n/ 42 sections done", attributes: lightAttrs))
            self.sectionsCompleted.attributedText = tagsCompletedString
            
            self.updateName()
            
            model.getTotalQuestionCounts() { result in
                self.countDict = result
                self.readingProgress.text = String(Int(user.Reading)) + " / " + String(Int(self.countDict["reading"]!)) + " questions"
                self.writingProgress.text = String(Int(user.Writing)) + " / " + String(Int(self.countDict["writing"]!)) + " questions"
                self.mathProgress.text = String(Int(user.Math)) + " / " + String(Int(self.countDict["math"]!)) + " questions"
                
                self.readingProgressBar.progress = Float(user.Reading) / Float(self.countDict["reading"]!)
                self.mathProgressBar.progress = Float(user.Math) / Float(self.countDict["math"]!)
                self.writingProgressBar.progress = Float(user.Writing) / Float(self.countDict["writing"]!)
                
                self.progressLabel.text = self.getProgressText()
            }
        }
        
        screenHeight = UIScreen.main.bounds.height
        nameLabel.font = nameLabel.font.withSize(screenHeight * 0.03)
        progressLabel.font = progressLabel.font.withSize(screenHeight * 0.02)
        readingProgress.font = readingProgress.font.withSize(screenHeight * 0.0175)
        writingProgress.font = writingProgress.font.withSize(screenHeight * 0.0175)
        mathProgress.font = mathProgress.font.withSize(screenHeight * 0.0175)
        mathLabel.font = mathProgress.font
        readingLabel.font = mathProgress.font
        writingLabel.font = mathProgress.font
        logOutButton.titleLabel?.font = logOutButton.titleLabel?.font.withSize(screenHeight * 0.02)
        
        hoursPracticed.layer.masksToBounds = false
        hoursPracticed.layer.applySketchShadow(
            color: UIColor(red:0.87, green:0.87, blue:0.87, alpha:0.5),
            alpha: 0.5,
            x: 0,
            y: 4,
            blur: 4,
            spread: 0)
        
        sectionsCompleted.layer.masksToBounds = false
        sectionsCompleted.layer.applySketchShadow(
            color: UIColor(red:0.87, green:0.87, blue:0.87, alpha:0.5),
            alpha: 0.5,
            x: 0,
            y: 4,
            blur: 4,
            spread: 0)
    }
    
    func updateName() {
        if user!.name != "" {
            self.nameLabel.text = "Hi " + user!.name.split(separator: " ")[0] + ","
        } else {
            self.nameLabel.text = "Hi!"
        }
    }
    
    func getProgressText() -> String{
        let subjects = ["Reading", "Writing", "Math"]
        let nonTargets = subjects.filter { $0 != user!.targetSubject }
        var dict = [String: Int]()
        dict["Math"] = user!.Math
        dict["Reading"] = user!.Reading
        dict["Writing"] = user!.Writing
        
        if dict["Math"] == 0 && dict["Writing"] == 0 && dict["Reading"] == 0 {
            if subjects.contains(user!.targetSubject) {
                return "Start answering some questions and see your overall progress here. We're excited to help you learn and we'll make sure you get lots of " + user!.targetSubject + " practice! \u{1F4AA}"
            } else {
                return "Start answering some questions and see your overall progress here. We're excited to help you learn! \u{1F4AA}"
            }
        } else if user!.Reading == countDict["reading"] && user!.Math == countDict["math"] && user!.Writing == countDict["writing"]{
            return "Wow! You've completed everything! We'll let you know when there's more questions to practice, but in the meantime, reward yourself with some well-deserved Netflix binging \u{1F64F}"
        } else if dict[nonTargets[0]] == dict[nonTargets[1]] && dict[nonTargets[0]]! > dict[user!.targetSubject]! {
            return "You're doing great at " + nonTargets[0] + " and " + nonTargets[1] + "! And we'll make sure you get some more " + user!.targetSubject + " practice as well \u{1F64C}"
        } else if dict[nonTargets[0]]! > dict[nonTargets[1]]! {
            return "You're breezing through " + nonTargets[0] + "! We'll get some extra " + user!.targetSubject + " questions ready to mix things up \u{270C}"
        } else if dict[nonTargets[0]]! < dict[nonTargets[1]]!{
            return "You're acing the " + nonTargets[1] + " questions! We'll prepare some extra " + user!.targetSubject + " practice for you to keep you on your toes \u{1F60E}"
        } else {
            return "Check out your progress below!"
        }
    }
    @IBAction func goToSettings(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingsController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController else {
            return
        }
        settingsController.user = self.user
        settingsController.modalPresentationStyle = .fullScreen
        self.present(settingsController, animated: true)
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firUser = Auth.auth().currentUser
        if firUser!.isAnonymous {
            guard let logOutController = storyboard.instantiateViewController(withIdentifier: "LogOut") as? LogOut else {
                return
            }
            logOutController.user = self.user
            logOutController.modalPresentationStyle = .fullScreen
            self.present(logOutController, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {[unowned self] action in
                let _ = try? Firebase.Auth.auth().signOut()
                           let loginManager = LoginManager()
                           loginManager.logOut()

                           guard let accountChoiceController = storyboard.instantiateViewController(withIdentifier: "AccountChoice") as? UIViewController else {
                               return
                           }
                           accountChoiceController.modalPresentationStyle = .fullScreen
                           self.present(accountChoiceController, animated: true)
            }))
           
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
