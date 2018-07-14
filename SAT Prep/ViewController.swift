//
//  ViewController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 5/15/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import UIKit
import Firebase
import UICountingLabel

class ViewController: UIViewController {
    var db: Firestore?
    var user: User?
    var question: Question?
    var model: Model?
    
    var navStreakLabel = UIImageView(image: UIImage(named:"Flame"))
    var navStreakCount = UILabel()
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var streakLabel: UICountingLabel!
    

    @IBAction func anotherButton(_ sender: UIButton) {
        
        model?.getQuestion(index: self.user!.index) {result in
            self.question = result
            if result.content.main.count > 0 {
                self.addChildViewController(self.longQuestionViewController)
            } else {
                self.addChildViewController(self.shortQuestionViewController)
            }
        }
    }
    
    //MARK: Child View Controllers
    private lazy var longQuestionViewController: LongQuestionViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "LongQuestionViewController") as! LongQuestionViewController
        viewController.question = self.question
        viewController.user = self.user
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var shortQuestionViewController: ShortQuestionViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ShortQuestionViewController") as! ShortQuestionViewController
        viewController.question = self.question
        viewController.user = self.user
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        successView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        model = Model()
        model?.getUser() {user in
            self.user = user
            let state = self.model?.checkStreak(user: user)
            if state == 0 {
                self.renderStreak()
            } else {
                self.model?.getQuestion(index: self.user!.index) {result in
                    self.question = result
                    if result.content.main.count > 0 {
                        self.addChildViewController(self.longQuestionViewController)
                    } else {
                        self.addChildViewController(self.shortQuestionViewController)
                    }
                }
            }
            self.renderHeader()
        }
        
    }
    
    func renderHeader() {
        navStreakLabel.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        navStreakLabel.contentMode = .scaleAspectFit
        
        navStreakCount.textAlignment = NSTextAlignment.center
        navStreakCount.textColor = UIColor(red:1.00, green:0.45, blue:0.29, alpha:1.0)
        navStreakCount.text = String((user?.streak)!)
        navStreakCount.font = navStreakCount.font.withSize(self.view.frame.height * 0.036)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill 
        stackView.distribution = .fill
        
        stackView.addArrangedSubview(navStreakLabel)
        stackView.addArrangedSubview(navStreakCount)
        
        navigationItem.titleView = stackView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func renderStreak() {
        let streak: Int = (user?.streak)!
        streakLabel.format = "%d"
        streakLabel.countFromZero(to: CGFloat(streak), withDuration: 1)
    }
    
    func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        
        view.addSubview(viewController.view)
        
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParentViewController: self)
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    func handleCorrect (vc: UIViewController) {
        updateUser()
        showSuccess()
        remove(asChildViewController: vc)
    }
    
    func handleWrong (vc: UIViewController) {
        add(asChildViewController: vc)
        addChildViewController(vc)
    }
    
    func showSuccess() {
        successView.isHidden = false
        self.perform(#selector(self.popupHide), with: self, afterDelay: 2)
    }
    
    @objc func popupHide() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let badgeVC = storyBoard.instantiateViewController(withIdentifier: "badgeDetailView") as! BadgeDetailViewController
        model?.getBadge(tag: (question?.tag)!) { result in
            badgeVC.badge = result
            self.present(badgeVC, animated:true, completion:nil)
        }
        
    }
    
    func updateUser() {
        let ref = db!.collection("users").document((self.user?.uid)!)
        let date = user?.last_answered
        let calendar = Calendar.current
        let today = Date()
        
        if date as? Int != 0 {
            let dict = date as AnyObject,
            d = dict.dateValue()
            let last_year = calendar.component(.year, from: d),
            last_month = calendar.component(.month, from: d),
            last_day = calendar.component(.day, from: d),
            today_year = calendar.component(.year, from: today),
            today_month = calendar.component(.month, from: today),
            today_day = calendar.component(.day, from: today),
            next_date = Calendar.current.date(byAdding: .day, value: 1, to: d)! as Date,
            next_year = calendar.component(.year, from: next_date),
            next_month = calendar.component(.month, from: next_date),
            next_day = calendar.component(.day, from: next_date)
            
            if last_year == today_year && last_month == today_month && last_day == today_day {
                self.user!.index += 1
                ref.updateData([
                    "qIndex": self.user!.index
                    ])
            } else if next_year == today_year && next_month == today_month && next_day == today_day {
                self.user!.last_answered = today
                self.user!.index += 1
                self.user!.streak += 1
                ref.updateData([
                    "last_answered": self.user!.last_answered,
                    "qIndex": self.user!.index,
                    "streak": self.user!.streak
                    ])
            } else {
                self.user!.last_answered = today
                self.user!.index += 1
                self.user!.streak = 1
                ref.updateData([
                    "last_answered": self.user!.last_answered,
                    "qIndex": self.user!.index,
                    "streak": self.user!.streak
                    ])
            }
        } else {
            self.user!.last_answered = today
            self.user!.index = 1
            self.user!.streak = 1
            ref.updateData([
                "last_answered": self.user!.last_answered,
                "qIndex": self.user!.index,
                "streak": self.user!.streak
                ])
        }
    }
}

