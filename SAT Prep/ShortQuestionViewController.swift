//
//  ShortQuestionViewController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 5/28/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import UIKit
import iosMath

class ShortQuestionViewController: UIViewController {
    var question: Question!
    var user: User?
    weak var parentVC: ViewController?
    
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    var elasticity: UIDynamicItemBehavior!
    var explanationController: ExplanationViewController?
    
    let orange = UIColor(red:1.00, green:0.53, blue:0.36, alpha:1.0)
    let grey = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
    
    private var makeExplanation: ExplanationViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        explanationController = (storyboard.instantiateViewController(withIdentifier: "ExplanationViewController") as! ExplanationViewController)
        
        return explanationController!
    }
    
    @IBOutlet weak var card: RoundedCornerView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var questionView: UIStackView!
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var buttonA: ChoiceButton!
    @IBOutlet weak var buttonB: ChoiceButton!
    @IBOutlet weak var buttonC: ChoiceButton!
    @IBOutlet weak var buttonD: ChoiceButton!
    
    @IBOutlet weak var buttonAHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonBHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonCHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonDHeight: NSLayoutConstraint!
    
    @IBAction func selectButtonA(_ sender: UIButton) {
        if question?.correctAnswer == 0 {
            parentVC?.handleCorrect(vc: self)
        } else {
            buttonA.mathLabel.textColor = UIColor.white
            buttonA.shapeLayer.fillColor = UIColor.gray.cgColor
            makeExplanation.explanations = question.answerA.explanations
            parentVC?.handleWrong(vc: explanationController!)
            buttonA.isEnabled = false
        }
    }
    
    @IBAction func selectButtonB(_ sender: UIButton) {
        if question?.correctAnswer == 1 {
            parentVC?.handleCorrect(vc: self)
        } else {
            buttonB.mathLabel.textColor = UIColor.white
            buttonB.shapeLayer.fillColor = UIColor.gray.cgColor
            makeExplanation.explanations = question.answerB.explanations
            parentVC?.handleWrong(vc: explanationController!)
            buttonB.isEnabled = false
        }
    }
    
    @IBAction func selectButtonC(_ sender: UIButton) {
        if question?.correctAnswer == 2 {
            parentVC?.handleCorrect(vc: self)
        } else {
            buttonC.mathLabel.textColor = UIColor.white
            buttonC.shapeLayer.fillColor = UIColor.gray.cgColor
            makeExplanation.explanations = question.answerC.explanations
            parentVC?.handleWrong(vc: explanationController!)
            buttonC.isEnabled = false
        }
    }
    
    @IBAction func selectButtonD(_ sender: UIButton) {
        if question?.correctAnswer == 3 {
            parentVC?.handleCorrect(vc: self)
        } else {
            buttonD.mathLabel.textColor = UIColor.white
            buttonD.shapeLayer.fillColor = UIColor.gray.cgColor
            makeExplanation.explanations = question.answerD.explanations
            parentVC?.handleWrong(vc: explanationController!)
            buttonD.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        parentVC = parent as? ViewController
        questionField.isHidden = true
        renderQuestion(q: question)
    }
    
    private func renderQuestion(q: Question) {
        let height = UIScreen.main.bounds.height / 10
        
        buttonAHeight.constant = height
        buttonBHeight.constant = height
        buttonCHeight.constant = height
        buttonDHeight.constant = height
        
        buttonA.shapeLayer.fillColor = orange.cgColor
        buttonB.shapeLayer.fillColor = orange.cgColor
        buttonC.shapeLayer.fillColor = orange.cgColor
        buttonD.shapeLayer.fillColor = orange.cgColor
        
        
        if q.text.range(of: "\\") != nil {
            let mathLabel = MTMathUILabel()
            mathLabel.latex = q.text
            mathLabel.fontSize = view.frame.height * 0.026
            mathLabel.textAlignment = MTTextAlignment.center
            mathLabel.contentInsets = UIEdgeInsetsMake(0, 0, 20, 0);
            questionView.insertArrangedSubview(mathLabel, at: 1)
        } else {
            questionField.text = q.text
            questionField.isHidden = false
        }
        
        if question.answerA.choiceText.range(of: "\\") != nil {
            createMathLabel(question.answerA.choiceText, buttonA)
            createMathLabel(question.answerB.choiceText, buttonB)
            createMathLabel(question.answerC.choiceText, buttonC)
            createMathLabel(question.answerD.choiceText, buttonD)
        } else {
            buttonA.setTitle(question.answerA.choiceText, for: .normal)
            buttonB.setTitle(question.answerB.choiceText, for: .normal)
            buttonC.setTitle(question.answerC.choiceText, for: .normal)
            buttonD.setTitle(question.answerD.choiceText, for: .normal)
        }
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        card.translatesAutoresizingMaskIntoConstraints = false
        
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior(items: [card])
        gravity.magnitude = 3.0
        animator.addBehavior(gravity)

        collision = UICollisionBehavior(items: [card])
        collision.addBoundary(withIdentifier: "center" as NSCopying, from: CGPoint(x: 0, y: view.frame.size.height*0.8), to: CGPoint(x: view.frame.size.width, y: view.frame.size.height*0.8))
        animator.addBehavior(collision)
    }
    
    private func createMathLabel(_ text: String, _ button: ChoiceButton) {
        button.mathLabel.latex = text
        button.mathLabel.sizeToFit()
        button.mathLabel.textColor = UIColor.white
        button.shapeLayer.fillColor = orange.cgColor
        button.addSubview(button.mathLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
