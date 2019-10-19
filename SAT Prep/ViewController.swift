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
    var error = false
    var loaded = false
    
    weak var longQuestionViewController: LongQuestionViewController?
    weak var shortQuestionViewController: ShortQuestionViewController?
    
    var colors = [UIColor(red:0.33, green:0.33, blue:0.42, alpha:1.0),
                  UIColor(red:0.37, green:0.79, blue:0.00, alpha:1.0),
                  UIColor(red:0.85, green:0.44, blue:0.18, alpha:1.0),
                  UIColor(red:0.92, green:0.00, blue:0.78, alpha:1.0),
                  UIColor(red:0.48, green:0.53, blue:0.88, alpha:1.0),
                  UIColor(red:0.56, green:0.43, blue:0.80, alpha:1.0),
                  UIColor(red:0.26, green:0.73, blue:0.88, alpha:1.0),
                  UIColor(red:0.00, green:0.66, blue:0.25, alpha:1.0),
                  UIColor(red:1.00, green:0.84, blue:0.18, alpha:1.0),
                  UIColor(red:1.00, green:0.28, blue:0.33, alpha:1.0),
                  UIColor(red:0.05, green:0.40, blue:0.75, alpha:1.0),
                  UIColor(red:0.34, green:0.90, blue:0.86, alpha:1.0),
                  UIColor(red:1.00, green:0.61, blue:0.00, alpha:1.0),
                  UIColor(red:1.00, green:0.63, blue:0.00, alpha:1.0)]
    
    @IBOutlet weak var getAnotherButton: UIButton!
    @IBOutlet weak var flameView: FLAnimatedImageView!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var streakLabel: UICountingLabel!
    @IBOutlet weak var streakStackView: UIStackView!
    @IBOutlet weak var errorStackView: UIStackView!
    @IBOutlet weak var errorView: LOTAnimatedControl!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var loadingMessage: UILabel!
    @IBOutlet weak var loadingView: LOTAnimatedControl!
    
    var loadingStrings = ["Putting together the perfect question for you...",
                          "Boris! Put down the cake and get a question ready!",
                          "An SAT question a day keeps your mom off your back.",
                          "Wake up Boris! Get a question ready!",
                          "You're here! Our day just got better.",
                          "If you squint really hard, SAT questions look like a Beyonce concert"]
    
    @IBAction func anotherButton(_ sender: UIButton) {
        renderHeader()
        let tagIndex = user!.index
        
        if badges.count == 0 {
            model?.getBadges() { [unowned self] results in
                self.badges = results
                self.fetchQuestion(model: self.model!, qIndex: (self.badges.filter({ [unowned self] in $0.tag == self.model!.tags[tagIndex] }).first?.lastIndex)!, tIndex: tagIndex, count: 0)
                self.renderHeader()
            }
        } else {
            fetchQuestion(model: self.model!, qIndex: (self.badges.filter({ [unowned self] in $0.tag == self.model!.tags[tagIndex] }).first?.lastIndex)!, tIndex: tagIndex, count: 0)
            renderHeader()
        }
    }
    
    func loadError() {
        error = true
        loadingStackView.isHidden = true
        streakStackView.isHidden = true
        errorStackView.spacing = view.frame.size.height*0.065
        errorStackView.isHidden = false
        errorView.animationView.setAnimation(named: "struggle")
        errorView.animationView.contentMode = .scaleAspectFit
        errorView.animationView.loopAnimation = true
        errorView.animationView.play()
    }
    
    @objc func renderLoading() {
        if !loaded && !error {
            loadingStackView.isHidden = false
            let number = Int(arc4random_uniform(UInt32(loadingStrings.count)))
            loadingMessage.text = loadingStrings[number]
            
            loadingView.animationView.setAnimation(named: "loading")
            loadingView.animationView.contentMode = .scaleAspectFill
            loadingView.animationView.loopAnimation = true
            loadingView.animationView.play()
        }
    }
    func loadQuestion(tagQuestion: Question?) {
        loaded = true
        if tagQuestion == nil {
            loadError()
            return
        }
        question = tagQuestion
        if badges.count == 0 {
            model?.getBadges() { [unowned self] results in
                self.badges = results
                self.renderHeader()
            }
        }
        loadingStackView.isHidden = true
        if tagQuestion!.content.main.count > 0 {
            addChildViewController(makeLongController)
        } else {
            addChildViewController(makeShortController)
        }
    }
    
    //MARK: Child View Controllers
    private var makeLongController: LongQuestionViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        longQuestionViewController = (storyboard.instantiateViewController(withIdentifier: "LongQuestionViewController") as! LongQuestionViewController)
        longQuestionViewController?.question = question
        longQuestionViewController?.user = user
        
        // Add View Controller as Child View Controller
        add(asChildViewController: longQuestionViewController!)
        
        return longQuestionViewController!
    }
    
    private var makeShortController: ShortQuestionViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        shortQuestionViewController = (storyboard.instantiateViewController(withIdentifier: "ShortQuestionViewController") as! ShortQuestionViewController)
        shortQuestionViewController?.question = question
        shortQuestionViewController?.user = user
        
        // Add View Controller as Child View Controller
        add(asChildViewController: shortQuestionViewController!)
        
        return shortQuestionViewController!
    }
    
    @objc func ProfileButtonTapped() {
        performSegue(withIdentifier: "signInSegue", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.popViewController(animated: true)
        successView.isHidden = true
        loadingStackView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.renderLoading()
        }
        db = Firestore.firestore()
        let settings = db?.settings
        settings?.isPersistenceEnabled = true
        settings?.areTimestampsInSnapshotsEnabled = true
        db?.settings = settings!
        model = Model()
        model?.getUser() {[unowned self] user in
            self.user = user
            let state = self.model?.checkStreak(user: user)
            if state == 0 {
                self.renderStreak()
            } else {
                let tagIndex = self.user!.index
                
                if self.badges.count == 0 {
                    self.model?.getBadges() { [unowned self] results in
                        self.badges = results
                        self.fetchQuestion(model: self.model!, qIndex: (self.badges.filter({ [unowned self] in $0.tag == self.model!.tags[tagIndex] }).first?.lastIndex)!, tIndex: tagIndex, count: 0)
                    }
                } else {
                    self.fetchQuestion(model: self.model!, qIndex: (self.badges.filter({[unowned self] in $0.tag == self.model!.tags[tagIndex] }).first?.lastIndex)!, tIndex: tagIndex, count: 0)
                }
                self.renderHeader()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
    }

    func requestFeedback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let alert = UIAlertController(title: "How can we improve this app? 🤔", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = ""
            })
            
            alert.addAction(UIAlertAction(title: "Send", style: .default, handler: {[unowned self] action in
                if let feedback = alert.textFields?.first?.text {
                    self.db?.collection("feedback").addDocument(data: [
                        "user": (self.user?.uid) as Any,
                        "feedback": feedback,
                    ])
                }
            }))
            
            self.present(alert, animated: true)
        }
    }
    
    func fetchQuestion(model: Model, qIndex: Int, tIndex: Int, count: Int) {
        if count == badges.count {
            loadError()
        }
        else {
            let viewControllers = childViewControllers
            
            if !(viewControllers.contains(where: { return $0 is LongQuestionViewController || $0 is ShortQuestionViewController})) && !error {
                
                model.getQuestion(tIndex: tIndex, qIndex: qIndex) {[unowned self] result in
                    if result == nil {
                        self.fetchQuestion(model: model, qIndex: (self.badges.filter({ [unowned self] in $0.tag == self.model!.tags[(tIndex + 1) % self.badges.count] }).first?.lastIndex)!, tIndex: (tIndex + 1) % self.badges.count, count: count + 1)
                        return
                    }
                    
                    self.question = result!
                    self.loadingStackView.isHidden = true
                    
                    if result!.content.main.count > 0 {
                        self.addChildViewController(self.makeLongController)
                    } else {
                        self.addChildViewController(self.makeShortController)
                    }
                    self.loaded = true
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
        navStreakCount.font = navStreakCount.font.withSize(view.frame.height * 0.036)
        
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
        loadingStackView.isHidden = true
        loaded = true
        navigationItem.titleView = UILabel()
        let streak: Int = (user?.streak)!
        streakLabel.format = "%d DAY STREAK"
        streakLabel.countFromZero(to: CGFloat(streak), withDuration: 0.2 * Double(streak))
        
        let flamePath : String = Bundle.main.path(forResource: "flame", ofType: "gif")!
        let url = URL(fileURLWithPath: flamePath)
        let gifData = try? Data(contentsOf: url)
        let imageData1 = FLAnimatedImage(animatedGIFData: gifData)
        flameView.animatedImage = imageData1
        flameView.contentMode = .scaleAspectFit
        UIView.transition(with: flameView, duration: 1.0, options: .curveEaseIn, animations: {[unowned self] in self.flameView.alpha = CGFloat(1.0)}, completion: nil)
        
        getAnotherButton.isHidden = false
        
        if question == nil{
            if !UserDefaults.standard.bool(forKey: "wasAlreadyShown") {
                UserDefaults.standard.set(true, forKey: "wasAlreadyShown")
                requestFeedback()
            }
        }
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
        Analytics.logEvent("correct_answer", parameters: [
            "tag": question?.tag ?? "",
            "index": question?.index ?? 0
        ])
        
        updateUser()
        showSuccess()
        remove(asChildViewController: vc)
    }
    
    func handleWrong (vc: UIViewController) {
        Analytics.logEvent("wrong_answer", parameters: [
            "tag": question?.tag ?? "",
            "index": question?.index ?? 0
        ])
        add(asChildViewController: vc)
        addChildViewController(vc)
    }
    
    func showSuccess() {
        loadingStackView.isHidden = true
        loaded = true
        
        renderHeader()
        successView.isHidden = false
        startConfetti()
        let animationView = LOTAnimationView(name: "check_animation")
        animationView.frame = CGRect(x:0, y:0, width: view.frame.size.width, height: view.frame.size.width)
        animationView.center.x = view.center.x
        animationView.center.y = view.center.y*0.8
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        animationView.animationSpeed = 0.5
        successView.addSubview(animationView)
        animationView.play()
        
        perform(#selector(self.popupHide), with: self, afterDelay: 3)
    }
    
    @objc func popupHide() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let badgeVC = storyBoard.instantiateViewController(withIdentifier: "badgeDetailView") as! BadgeDetailViewController
        let tags = model?.readTags()[(question?.subject)!.lowercased()]
        let index = question!.tag
        badgeVC.color = colors[(tags?.index(of: index))!]
        badgeVC.badge = (badges.filter({ $0.tag == question?.tag }).first)!
        navigationController?.pushViewController(badgeVC, animated: true)
    }
    
    func updateUser() {
        let ref = db!.collection("users").document((user?.uid)!)
        let badgeRef = db!.collection("users").document((user?.uid)!).collection("badges").document((question?.tag)!)
        let date = user?.last_answered
        let calendar = Calendar.current
        let today = Date()
        let tagIndex = (badges.index(where: { $0.tag == question?.tag }))!
        
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
                user!.index = (user!.index + 1) % 32
                badges[tagIndex].update(index: (question?.index)!)
                ref.updateData([
                    "qIndex": user!.index
                    ])
                badgeRef.updateData([
                    "lastIndex": badges[tagIndex].lastIndex,
                    "progress": badges[tagIndex].progress
                    ])
            } else if next_year == today_year && next_month == today_month && next_day == today_day {
                user!.last_answered = today
                user!.index = (user!.index + 1) % 32
                badges[tagIndex].update(index: (question?.index)!)
                user!.streak += 1
                ref.updateData([
                    "last_answered": user!.last_answered,
                    "qIndex": user!.index,
                    "streak": user!.streak
                    ])
                badgeRef.updateData([
                    "lastIndex": badges[tagIndex].lastIndex,
                    "progress": badges[tagIndex].progress
                    ])
            } else {
                user!.last_answered = today
                user!.index = (user!.index + 1) % 32
                badges[tagIndex].update(index: (question?.index)!)
                user!.streak = 1
                ref.updateData([
                    "last_answered": user!.last_answered,
                    "qIndex": user!.index,
                    "streak": user!.streak
                    ])
                badgeRef.updateData([
                    "lastIndex": badges[tagIndex].lastIndex,
                    "progress": badges[tagIndex].progress
                    ])
            }
        } else {
            user!.last_answered = today
            user!.index = 1
            user!.streak = 1
            badges[tagIndex].update(index: (question?.index)!)
            ref.updateData([
                "last_answered": user!.last_answered,
                "qIndex": user!.index,
                "streak": user!.streak
                ])
            badgeRef.updateData([
                "lastIndex": badges[tagIndex].lastIndex,
                "progress": badges[tagIndex].progress
                ])
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.model?.getNextQuestions(badges: self.badges)
        }
    }
    
    public func startConfetti() {
        let emitter = CAEmitterLayer()
        let colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
                  UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
                  UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
                  UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
                  UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        emitter.emitterPosition = CGPoint(x: view.frame.size.width / 2.0, y: 0)
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)
        
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

