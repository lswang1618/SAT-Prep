//
//  ExplanationViewController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 6/2/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import UIKit
import iosMath

class ExplanationViewController: UIViewController, UIDynamicAnimatorDelegate {
    var explanations: Array<Explanation> = []
    var currentExplanation: Explanation?
    
    var newCardView: RoundedCornerView!
    var oldCardView: RoundedCornerView!
    
    var animatorIn: UIDynamicAnimator!
    var gravityIn: UIGravityBehavior!
    var collisionIn: UICollisionBehavior!
    var elasticityIn: UIDynamicItemBehavior!

    var animatorOut: UIDynamicAnimator!
    var gravityOut: UIGravityBehavior!
    var collisionOut: UICollisionBehavior!
    //var elasticityOut: UIDynamicItemBehavior!

    let mint = UIColor(red:0.00, green:0.58, blue:0.74, alpha:1.0)
    let orange = UIColor(red:1.00, green:0.53, blue:0.36, alpha:1.0)
    
    @objc func selectChoiceA(_ sender: UIButton) {
        if currentExplanation?.correctChoice == 0 {
            explanations.remove(at:0)
            if explanations.count > 0 {
                currentExplanation = explanations[0]
                renderExplanation(e: currentExplanation!)
            } else {
                removeView()
            }
        } else {
            // flash wrong answer
        }
    }
    
    @objc func selectChoiceB(_ sender: UIButton) {
        if currentExplanation?.correctChoice == 1 {
            explanations.remove(at:0)
            if explanations.count > 0 {
                currentExplanation = explanations[0]
                renderExplanation(e: currentExplanation!)
            } else {
                removeView()
            }
        } else {
            // flash wrong answer
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let parent = self.parent as! ViewController
        parent.navigationController?.navigationBar.barTintColor = UIColor(red:1.00, green:0.39, blue:0.42, alpha:1.0)
        parent.navStreakLabel.image = UIImage(named:"White_Flame")
        parent.navStreakCount.textColor = UIColor.white
        
        currentExplanation = explanations[0]
        renderExplanation(e: currentExplanation!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let parent = self.parent as! ViewController
        parent.navigationController?.navigationBar.barTintColor = UIColor(red:1.00, green:0.39, blue:0.42, alpha:1.0)
    }
    
    func removeView() {
        let parent = self.parent as! ViewController
        parent.remove(asChildViewController: self)
        
        parent.navigationController?.navigationBar.barTintColor = mint
        parent.navStreakLabel.image = UIImage(named:"Flame")
        parent.navStreakCount.textColor = orange
    }
    
    func renderButton(button: UIButton) {
        button.titleLabel?.font = UIFont(name: "DinPro-Light", size: view.frame.height*0.02)!
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 3
        button.layer.borderColor = mint.cgColor
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
    }
    
    func renderExplanation(e: Explanation) {
        if newCardView != nil {
            animatorOut = UIDynamicAnimator(referenceView: view)
            gravityOut = UIGravityBehavior(items: [newCardView])
            gravityOut.gravityDirection = CGVector(dx: -1.0, dy: 0.0)
            gravityOut.magnitude = 2.0
            animatorOut.addBehavior(gravityOut)
            
            collisionOut = UICollisionBehavior(items: [newCardView])
            collisionOut.addBoundary(withIdentifier: "center" as NSCopying, from: CGPoint(x: -1 * view.frame.size.width, y: 0), to: CGPoint(x: -1 * view.frame.size.width, y: view.frame.size.height))
            animatorOut.addBehavior(collisionOut)
        }
        let deviceHeight = self.parent?.view.frame.height
        
        let deviceWidth = UIScreen.main.bounds.size.width
        let navHeight = self.navigationController?.navigationBar.frame.size.height
        
        newCardView = RoundedCornerView(frame: CGRect(x: deviceWidth, y: 0, width: deviceWidth - 40 , height: (deviceHeight! - navHeight!)*0.9))
        newCardView.backgroundColor = UIColor.white
        newCardView.cornerRadius = 25
        
        
        let buttonA = UIButton(type: .system) as UIButton
        buttonA.addTarget(self, action: #selector(self.selectChoiceA(_:)), for: UIControlEvents.touchUpInside)
        buttonA.setTitle(e.choiceA, for: .normal)
        renderButton(button: buttonA)
        
        let buttonB = UIButton(type: .system) as UIButton
        buttonB.addTarget(self, action: #selector(self.selectChoiceB(_:)), for: UIControlEvents.touchUpInside)
        buttonB.setTitle(e.choiceB, for: .normal)
        renderButton(button: buttonB)
        
        let text = UILabel()
        text.lineBreakMode = .byWordWrapping
        text.numberOfLines = 0
        text.text = e.explanationText
        text.textColor = UIColor.black
        text.font = UIFont(name: "DinPro-Light", size: view.frame.height*0.024)!
        text.textAlignment = NSTextAlignment.center
        
        let stackView = UIStackView(arrangedSubviews: [text, buttonA, buttonB])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 40
        stackView.translatesAutoresizingMaskIntoConstraints = false
        newCardView.addSubview(stackView)
        
        newCardView.center.y = ((self.parent?.view.center.y)! - navHeight!) * 0.88
        
        let viewsDictionary = ["stackView": stackView]
        let stackView_H = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-40-[stackView]-40-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-40-[stackView]-40-|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil,
            views: viewsDictionary)
        newCardView.addConstraints(stackView_H)
        newCardView.addConstraints(stackView_V)
        
        self.view.addSubview(newCardView)
        
        animatorIn = UIDynamicAnimator(referenceView: view)
        gravityIn = UIGravityBehavior(items: [newCardView])
        gravityIn.gravityDirection = CGVector(dx: -1.0, dy: 0.0)
        gravityIn.magnitude = 2.0
        animatorIn.addBehavior(gravityIn)
        
        collisionIn = UICollisionBehavior(items: [newCardView])
        collisionIn.addBoundary(withIdentifier: "center" as NSCopying, from: CGPoint(x: view.frame.size.width*0.05, y: 0), to: CGPoint(x: view.frame.size.width*0.05, y: view.frame.size.height))
        animatorIn.addBehavior(collisionIn)
        
        elasticityIn = UIDynamicItemBehavior(items: [newCardView])
        elasticityIn.elasticity = 0.4
        animatorIn.addBehavior(elasticityIn)
    }
}
