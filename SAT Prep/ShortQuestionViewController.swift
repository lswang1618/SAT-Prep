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
    var parentVC: ViewController?
    
    private lazy var explanationController: ExplanationViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ExplanationViewController") as! ExplanationViewController
        
        return viewController
    }()
    
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
            self.explanationController.explanations = question.answerA.explanations
            parentVC?.handleWrong(vc: self.explanationController)
            buttonA.isEnabled = false
        }
    }
    
    @IBAction func selectButtonB(_ sender: UIButton) {
        if question?.correctAnswer == 1 {
            parentVC?.handleCorrect(vc: self)
        } else {
            self.explanationController.explanations = question.answerB.explanations
            parentVC?.handleWrong(vc: self.explanationController)
            buttonB.isEnabled = false
        }
    }
    
    @IBAction func selectButtonC(_ sender: UIButton) {
        if question?.correctAnswer == 2 {
            parentVC?.handleCorrect(vc: self)
        } else {
            self.explanationController.explanations = question.answerC.explanations
            parentVC?.handleWrong(vc: self.explanationController)
            buttonC.isEnabled = false
        }
    }
    
    @IBAction func selectButtonD(_ sender: UIButton) {
        if question?.correctAnswer == 3 {
            parentVC?.handleCorrect(vc: self)
        } else {
            self.explanationController.explanations = question.answerD.explanations
            parentVC?.handleWrong(vc: self.explanationController)
            buttonD.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        parentVC = self.parent as? ViewController
        questionField.isHidden = true
        renderQuestion(q: question)
    }
    
    private func renderQuestion(q: Question) {
        let height = UIScreen.main.bounds.height / 10
        
        buttonAHeight.constant = height
        buttonBHeight.constant = height
        buttonCHeight.constant = height
        buttonDHeight.constant = height
        
        if q.subject == "Math" {
            let mathLabel = MTMathUILabel()
            mathLabel.latex = q.text
            mathLabel.sizeToFit()
            mathLabel.textAlignment = MTTextAlignment.center
            questionView.insertArrangedSubview(mathLabel, at: 0)

            createMathLabel(question.answerA.choiceText, buttonA)
            createMathLabel(question.answerB.choiceText, buttonB)
            createMathLabel(question.answerC.choiceText, buttonC)
            createMathLabel(question.answerD.choiceText, buttonD)
        } else {
            questionField.text = q.text
            questionField.isHidden = false
            
            buttonA.setTitle(question.answerA.choiceText, for: .normal)
            buttonB.setTitle(question.answerB.choiceText, for: .normal)
            buttonC.setTitle(question.answerC.choiceText, for: .normal)
            buttonD.setTitle(question.answerD.choiceText, for: .normal)
        }
    }
    
    private func createMathLabel(_ text: String, _ button: ChoiceButton) {
        button.mathLabel.latex = text
        button.mathLabel.sizeToFit()
        button.mathLabel.textColor = UIColor.white
        button.shapeLayer.fillColor = UIColor(red:0.00, green:0.51, blue:0.69, alpha:1.0).cgColor
        button.addSubview(button.mathLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
