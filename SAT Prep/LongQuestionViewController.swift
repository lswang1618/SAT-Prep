//
//  LongQuestionViewController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 5/28/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import UIKit
import iosMath

class LongQuestionViewController: UIViewController {
    var question: Question!
    var user: User?
    var parentVC: ViewController?
    
    let mint = UIColor(red:0.00, green:0.51, blue:0.69, alpha:1.0)
    
    private lazy var explanationController: ExplanationViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ExplanationViewController") as! ExplanationViewController
        
        return viewController
    }()
    
    //MARK: Modal Question Properties
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var questionView: UIStackView!

    @IBOutlet weak var buttonA: ChoiceA!
    @IBOutlet weak var buttonB: ChoiceB!
    @IBOutlet weak var buttonC: ChoiceC!
    @IBOutlet weak var buttonD: ChoiceD!
    
    @IBOutlet weak var buttonAHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonBHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonCHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonDHeight: NSLayoutConstraint!
    
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: Actions
    @IBAction func selectChoiceA(_ sender: UIButton) {
        if question?.correctAnswer == 0 {
            parentVC?.handleCorrect(vc: self)
        } else {
            self.explanationController.explanations = question.answerA.explanations
            parentVC?.handleWrong(vc: self.explanationController)
            buttonA.isEnabled = false
        }
    }
    
    @IBAction func selectChoiceB(_ sender: UIButton) {
        if question?.correctAnswer == 1 {
            parentVC?.handleCorrect(vc: self)
        } else {
            self.explanationController.explanations = question.answerB.explanations
            parentVC?.handleWrong(vc: self.explanationController)
            buttonB.isEnabled = false
        }
    }
    
    @IBAction func selectChoiceC(_ sender: UIButton) {
        if question?.correctAnswer == 2 {
            parentVC?.handleCorrect(vc: self)
        } else {
            self.explanationController.explanations = question.answerC.explanations
            parentVC?.handleWrong(vc: self.explanationController)
            buttonC.isEnabled = false
        }
    }
    
    @IBAction func selectChoiceD(_ sender: UIButton) {
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
        
        scrollView.layer.cornerRadius = 20
        questionField.isHidden = true
        renderQuestion(q: question)
        renderContent(q: question)
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        
        if let view = recognizer.view {
            let viewHeight = view.frame.height
            let deviceHeight = view.superview?.frame.height
            view.center = CGPoint(x:view.center.x,
                                  y: min(deviceHeight!*0.89 + viewHeight*0.5, max(view.center.y + translation.y, deviceHeight! - viewHeight*0.5)))
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func handleTap(recognizer:UITapGestureRecognizer) {
        if let view = recognizer.view?.superview?.superview {
            let deviceHeight = view.superview?.frame.height
            let viewY = view.frame.minY
            let viewHeight = view.frame.height
            
            if viewY > deviceHeight! - viewHeight {
                view.center = CGPoint(x: view.center.x, y: deviceHeight! - viewHeight*0.5)
            }
            else if view.center.y == deviceHeight! - viewHeight*0.5 {
                view.center = CGPoint(x: view.center.x, y: deviceHeight!*0.89 + viewHeight*0.5)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func renderQuestion(q: Question) {
        let height = UIScreen.main.bounds.height / 10
        
        buttonAHeight.constant = height
        buttonBHeight.constant = height
        buttonCHeight.constant = height
        buttonDHeight.constant = height
        
        buttonA.shapeLayer.fillColor = mint.cgColor
        buttonB.shapeLayer.fillColor = mint.cgColor
        buttonC.shapeLayer.fillColor = mint.cgColor
        buttonD.shapeLayer.fillColor = mint.cgColor
        
        if q.subject == "Math" {
            let mathLabel = MTMathUILabel()
            mathLabel.latex = q.text
            mathLabel.sizeToFit()
            mathLabel.textAlignment = MTTextAlignment.center
            questionView.insertArrangedSubview(mathLabel, at: 1)
            
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
        button.mathLabel.textColor = UIColor.black
        button.addSubview(button.mathLabel)
    }
    
    private func renderContent(q: Question) {
        contentStackView.layoutMargins = UIEdgeInsets(top: 15, left: 8, bottom: 15, right: 8)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        let content = q.content
        let space = "       "
        
        let titleLabel = UILabel()
        let introLabel = UILabel()
        let mainLabel = UILabel()
        let image = UIImageView()
        let labels = content.labels
        
        if content.title != "" {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.numberOfLines = 0
            titleLabel.text = content.title.replacingOccurrences(of: "\\n", with: "\n" + space)
            titleLabel.font = UIFont.systemFont(ofSize: 22)
            contentStackView.addArrangedSubview(titleLabel)
        }
        if content.intro != "" {
            introLabel.translatesAutoresizingMaskIntoConstraints = false
            introLabel.numberOfLines = 0
            introLabel.font = UIFont.systemFont(ofSize: 22)
            introLabel.text = content.intro.replacingOccurrences(of: "\\n", with: "\n" + space)
            contentStackView.addArrangedSubview(introLabel)
        }
        if content.image != "" {
            do {
                let imageURL = URL(string: content.image)
                let data = try Data(contentsOf: imageURL!)
                image.image = UIImage(data: data)
                contentStackView.addArrangedSubview(image)
                image.contentMode = .scaleAspectFit
            }
            catch{
                print(error)
            }
        }
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.numberOfLines = 0
        mainLabel.font = UIFont(name: "Georgia", size: 16)
        
        let cArray = content.main
        
        if content.labels.count == 0 {
            mainLabel.text = space + cArray[0].replacingOccurrences(of: "\\n", with: "\n" + space)
        } else {
            let attributedString = NSMutableAttributedString(string: space)
            if content.useLabels  {
                let iconSize = CGRect(x: 0, y: -5, width: 30, height: 30)
                let iconList = [UIImage(named: "iconA"), UIImage(named: "iconB"), UIImage(named: "iconC"), UIImage(named: "iconD")]
            
                var counter = 0
                for i in 0...cArray.count-1 {
                    if labels.contains(i) {
                        let attachment = NSTextAttachment()
                        attachment.image = iconList[counter]
                        attachment.bounds = iconSize
                        attributedString.append(NSAttributedString(attachment: attachment))
                        counter += 1
                        let attrs = [NSAttributedStringKey.foregroundColor : mint]//, NSAttributedStringKey.backgroundColor : mint]
                        attributedString.append(NSMutableAttributedString(string:cArray[i].replacingOccurrences(of: "\\n", with: "\n" + space), attributes:attrs))
                    } else {
                        attributedString.append(NSMutableAttributedString(string: cArray[i].replacingOccurrences(of: "\\n", with: "\n" + space)))
                    }
                }
            }
            else {
                for i in 0...cArray.count-1 {
                    if labels.contains(i) {
                        let attrs = [NSAttributedStringKey.foregroundColor : mint]//, NSAttributedStringKey.backgroundColor : mint]
                        attributedString.append(NSMutableAttributedString(string:cArray[i].replacingOccurrences(of: "\\n", with: "\n" + space), attributes:attrs))
                    } else {
                        attributedString.append(NSMutableAttributedString(string: cArray[i].replacingOccurrences(of: "\\n", with: "\n" + space)))
                    }
                }
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
            mainLabel.attributedText = attributedString
        }
        
        contentStackView.addArrangedSubview(mainLabel)
        
    }
}
