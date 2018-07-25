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
import Lottie
import FLAnimatedImage

class ViewController: UIViewController {
    var db: Firestore?
    var user: User?
    var question: Question?
    var model: Model?
    var badges: Array<Badge> = []
    var navStreakLabel = UIImageView(image: UIImage(named:"Flame"))
    var navStreakCount = UILabel()
    
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    var elasticity: UIDynamicItemBehavior!
    
    @IBOutlet weak var getAnotherButton: UIButton!
    @IBOutlet weak var flameView: FLAnimatedImageView!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var streakLabel: UICountingLabel!
    @IBOutlet weak var streakStackView: UIStackView!
    
    
    @IBAction func anotherButton(_ sender: UIButton) {
        let tagIndex = self.user!.index
        if self.badges.count == 0 {
            self.model?.getBadges() { results in
                self.badges = results
                self.fetchQuestion(model: self.model!, qIndex: (self.badges.filter({ $0.tag == self.model!.tags[tagIndex] }).first?.lastIndex)!, tIndex: tagIndex)
            }
        } else {
            self.fetchQuestion(model: self.model!, qIndex: (self.badges.filter({ $0.tag == self.model!.tags[tagIndex] }).first?.lastIndex)!, tIndex: tagIndex)
        }
        self.renderHeader()
    }
    
    func loadQuestion(tagQuestion: Question) {
        self.question = tagQuestion
        if self.badges.count == 0 {
            self.model?.getBadges() { results in
                self.badges = results
            }
        }
    
        if tagQuestion.content.main.count > 0 {
            self.addChildViewController(self.longQuestionViewController)
        } else {
            self.addChildViewController(self.shortQuestionViewController)
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
        
        db = Firestore.firestore()
        model = Model()
        
        model?.getUser() {user in
            self.user = user
            let state = self.model?.checkStreak(user: user)
            if state == 0 {
                self.renderStreak()
            } else {
                let tagIndex = self.user!.index
                if self.badges.count == 0 {
                    self.model?.getBadges() { results in
                        self.badges = results
                        self.fetchQuestion(model: self.model!, qIndex: (self.badges.filter({ $0.tag == self.model!.tags[tagIndex] }).first?.lastIndex)!, tIndex: tagIndex)
                    }
                } else {
                    self.fetchQuestion(model: self.model!, qIndex: (self.badges.filter({ $0.tag == self.model!.tags[tagIndex] }).first?.lastIndex)!, tIndex: tagIndex)
                }
                self.renderHeader()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func fetchQuestion(model: Model, qIndex: Int, tIndex: Int) {
        if self.question == nil {
            model.getQuestion(tIndex: tIndex, qIndex: qIndex) {result in
                self.question = result
                if result.content.main.count > 0 {
                    self.addChildViewController(self.longQuestionViewController)
                } else {
                    self.addChildViewController(self.shortQuestionViewController)
                }
            }
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
        navigationItem.titleView = UILabel()
        let streak: Int = (user?.streak)!
        streakLabel.format = "%d DAY STREAK"
        streakLabel.countFromZero(to: CGFloat(streak), withDuration: 0.2 * Double(streak))
        
        let flamePath : String = Bundle.main.path(forResource: "flame", ofType: "gif")!
        let url = URL(fileURLWithPath: flamePath)
        let gifData = try? Data(contentsOf: url)
        let imageData1 = try? FLAnimatedImage(animatedGIFData: gifData)
        flameView.animatedImage = imageData1
        flameView.contentMode = .scaleAspectFit
        getAnotherButton.isHidden = false
        
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior(items: [streakStackView])
        animator.addBehavior(gravity)
        
        
        collision = UICollisionBehavior(items: [streakStackView])
        collision.addBoundary(withIdentifier: "center" as NSCopying, from: CGPoint(x: 0, y: view.frame.size.height*0.5), to: CGPoint(x: view.frame.size.width, y: view.frame.size.height*0.5))
        animator.addBehavior(collision)
        
        elasticity = UIDynamicItemBehavior(items: [streakStackView])
        elasticity.elasticity = 0.6
        animator.addBehavior(elasticity)
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
        renderHeader()
        successView.isHidden = false
        startConfetti()
        let animationView = LOTAnimationView(name: "check_animation")
        animationView.frame = CGRect(x:0, y:0, width: view.frame.size.width, height: view.frame.size.width)
        animationView.center.x = self.view.center.x
        animationView.center.y = self.view.center.y*0.8
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        animationView.animationSpeed = 0.5
        successView.addSubview(animationView)
        animationView.play()
        
        self.perform(#selector(self.popupHide), with: self, afterDelay: 3)
    }
    
    @objc func popupHide() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let badgeVC = storyBoard.instantiateViewController(withIdentifier: "badgeDetailView") as! BadgeDetailViewController
        badgeVC.badge = (self.badges.filter({ $0.tag == question?.tag }).first)!
        self.navigationController?.pushViewController(badgeVC, animated: true)
    }
    
    func updateUser() {
        let ref = db!.collection("users").document((self.user?.uid)!)
        let badgeRef = db!.collection("users").document((self.user?.uid)!).collection("badges").document((question?.tag)!)
        let date = user?.last_answered
        let calendar = Calendar.current
        let today = Date()
        let tagIndex = (self.badges.index(where: { $0.tag == question?.tag }))!
        
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
                self.user!.index = (self.user!.index + 1) % 32
                self.badges[tagIndex].update(index: (self.question?.index)!)
                ref.updateData([
                    "qIndex": self.user!.index
                    ])
                badgeRef.updateData([
                    "lastIndex": self.badges[tagIndex].lastIndex,
                    "progress": self.badges[tagIndex].progress
                    ])
            } else if next_year == today_year && next_month == today_month && next_day == today_day {
                self.user!.last_answered = today
                self.user!.index = (self.user!.index + 1) % 32
                self.badges[tagIndex].update(index: (self.question?.index)!)
                self.user!.streak += 1
                ref.updateData([
                    "last_answered": self.user!.last_answered,
                    "qIndex": self.user!.index,
                    "streak": self.user!.streak
                    ])
                badgeRef.updateData([
                    "lastIndex": self.badges[tagIndex].lastIndex,
                    "progress": self.badges[tagIndex].progress
                    ])
            } else {
                self.user!.last_answered = today
                self.user!.index = (self.user!.index + 1) % 32
                self.badges[tagIndex].update(index: (self.question?.index)!)
                self.user!.streak = 1
                ref.updateData([
                    "last_answered": self.user!.last_answered,
                    "qIndex": self.user!.index,
                    "streak": self.user!.streak
                    ])
                badgeRef.updateData([
                    "lastIndex": self.badges[tagIndex].lastIndex,
                    "progress": self.badges[tagIndex].progress
                    ])
            }
        } else {
            self.user!.last_answered = today
            self.user!.index = 1
            self.user!.streak = 1
            self.badges[tagIndex].update(index: (self.question?.index)!)
            ref.updateData([
                "last_answered": self.user!.last_answered,
                "qIndex": self.user!.index,
                "streak": self.user!.streak
                ])
            badgeRef.updateData([
                "lastIndex": self.badges[tagIndex].lastIndex,
                "progress": self.badges[tagIndex].progress
                ])
        }
    }
    
    public func startConfetti() {
        let emitter = CAEmitterLayer()
        let colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
                  UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
                  UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
                  UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
                  UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        emitter.emitterPosition = CGPoint(x: self.view.frame.size.width / 2.0, y: 0)
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterSize = CGSize(width: self.view.frame.size.width, height: 1)
        
        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color: color))
        }
        
        emitter.emitterCells = cells
        successView.layer.addSublayer(emitter)

    }
    
    func confettiWithColor(color: UIColor) -> CAEmitterCell {
        let intensity = Float(1.0)
        let confetti = CAEmitterCell()
        confetti.birthRate = 10.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.emissionRange = CGFloat(Double.pi)
        confetti.spin = CGFloat(1.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = UIImage(named: "confettibar")!.cgImage
        return confetti
    }
}

