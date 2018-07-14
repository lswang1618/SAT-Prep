//
//  ExplanationViewController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 6/2/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import UIKit
import iosMath

class ExplanationViewController: UIViewController {
    var explanations: Array<Explanation> = []
    var currentExplanation: Explanation?
    
    var newCardView: RoundedCornerView!
    var oldCardView: RoundedCornerView!
    
    let mint = UIColor(red:0.00, green:0.51, blue:0.69, alpha:1.0)
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
        parent.navigationController?.navigationBar.barTintColor = UIColor(red:0.00, green:0.51, blue:0.69, alpha:1.0)
        parent.navStreakLabel.image = UIImage(named:"White_Flame")
        parent.navStreakCount.textColor = UIColor.white
        
        currentExplanation = explanations[0]
        renderExplanation(e: explanations[0])
    }
    
    func removeView() {
        let parent = self.parent as! ViewController
        parent.remove(asChildViewController: self)
        
        parent.navigationController?.navigationBar.barTintColor = mint
        parent.navStreakLabel.image = UIImage(named:"Flame")
        parent.navStreakCount.textColor = orange
    }
    
    func renderExplanation(e: Explanation) {
        if newCardView != nil {
            newCardView.removeFromSuperview()
        }
        
        let deviceHeight = self.parent?.view.frame.height
        
        let deviceWidth = UIScreen.main.bounds.size.width
        let navHeight = self.navigationController?.navigationBar.frame.size.height
        
        newCardView = RoundedCornerView(frame: CGRect(x: 0, y: 0, width: deviceWidth - 40 , height: (deviceHeight! - navHeight!)*0.9))
        newCardView.backgroundColor = UIColor.white
        newCardView.cornerRadius = 25
        
        
        let buttonA = UIButton(type: .system) as UIButton
        buttonA.addTarget(self, action: #selector(self.selectChoiceA(_:)), for: UIControlEvents.touchUpInside)
        buttonA.setTitle(e.choiceA, for: .normal)
        buttonA.setTitleColor(UIColor.black, for: .normal)
        
        let buttonB = UIButton(type: .system) as UIButton
        buttonB.addTarget(self, action: #selector(self.selectChoiceB(_:)), for: UIControlEvents.touchUpInside)
        buttonB.setTitle(e.choiceB, for: .normal)
        buttonB.setTitleColor(UIColor.black, for: .normal)
        
        let text = UILabel()
        text.text = e.explanationText
        text.textColor = UIColor.black
        
        let stackView = UIStackView(arrangedSubviews: [text, buttonA, buttonB])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        newCardView.addSubview(stackView)
        
        newCardView.center.x = (self.parent?.view.center.x)!
        newCardView.center.y = ((self.parent?.view.center.y)! - navHeight!) * 0.88
        
        let viewsDictionary = ["stackView": stackView]
        let stackView_H = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-20-[stackView]-20-|",  //horizontal constraint 20 points from left and right side
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-30-[stackView]-30-|", //vertical constraint 30 points from top and bottom
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil,
            views: viewsDictionary)
        newCardView.addConstraints(stackView_H)
        newCardView.addConstraints(stackView_V)
        
        self.view.addSubview(newCardView)
    }
}
