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
    weak var parentVC: ViewController?
    
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    var elasticity: UIDynamicItemBehavior!
    weak var explanationController: ExplanationViewController?
    weak var storyController: StoryViewController?
    
    let mint = UIColor(red:0.00, green:0.58, blue:0.74, alpha:1.0)
    
    private var makeExplanation: ExplanationViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        explanationController = (storyboard.instantiateViewController(withIdentifier: "ExplanationViewController") as! ExplanationViewController)
        
        return explanationController!
    }
    
    private var makeStory: StoryViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        storyController = (storyboard.instantiateViewController(withIdentifier: "StoryViewController") as! StoryViewController)
        storyController?.storyID = question.content.storyID
        return storyController!
    }
    
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
    @IBOutlet weak var card: RoundedCornerView!
    @IBOutlet weak var answers: UIView!
    
    //MARK: Actions
    @IBAction func selectChoiceA(_ sender: UIButton) {
        if question?.correctAnswer == 0 {
            parentVC?.handleCorrect(vc: self)
        } else {
            buttonA.mathLabel.textColor = UIColor.gray
            buttonA.shapeLayer.fillColor = UIColor.gray.cgColor
            makeExplanation.explanations = question.answerA.explanations
            parentVC?.handleWrong(vc: explanationController!)
            buttonA.isEnabled = false
        }
    }
    
    @IBAction func selectChoiceB(_ sender: UIButton) {
        if question?.correctAnswer == 1 {
            parentVC?.handleCorrect(vc: self)
        } else {
            buttonB.mathLabel.textColor = UIColor.gray
            buttonB.shapeLayer.fillColor = UIColor.gray.cgColor
            makeExplanation.explanations = question.answerB.explanations
            parentVC?.handleWrong(vc: explanationController!)
            buttonB.isEnabled = false
        }
    }
    
    @IBAction func selectChoiceC(_ sender: UIButton) {
        if question?.correctAnswer == 2 {
            parentVC?.handleCorrect(vc: self)
        } else {
            buttonC.mathLabel.textColor = UIColor.gray
            buttonC.shapeLayer.fillColor = UIColor.gray.cgColor
            makeExplanation.explanations = question.answerC.explanations
            parentVC?.handleWrong(vc: explanationController!)
            buttonC.isEnabled = false
        }
    }
    
    @IBAction func selectChoiceD(_ sender: UIButton) {
        if question?.correctAnswer == 3 {
            parentVC?.handleCorrect(vc: self)
        } else {
            buttonD.mathLabel.textColor = UIColor.gray
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
        
        scrollView.layer.cornerRadius = 20
        questionField.isHidden = true
        renderQuestion(q: question)
        renderContent(q: question)
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        
        if let view = recognizer.view {
            let viewHeight = view.frame.height
            let deviceHeight = view.superview?.frame.height
            view.center = CGPoint(x:view.center.x,
                                  y: min(deviceHeight!*0.88 + viewHeight*0.5, max(view.center.y + translation.y, deviceHeight! - viewHeight*0.5)))
        }
        recognizer.setTranslation(CGPoint.zero, in: view)
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
                view.center = CGPoint(x: view.center.x, y: deviceHeight!*0.88 + viewHeight*0.5)
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
        
        if q.text.range(of: "\\") != nil {
            let mathLabel = MTMathUILabel()
            mathLabel.latex = q.text
            mathLabel.sizeToFit()
            mathLabel.textAlignment = MTTextAlignment.center
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
            let aText = question.answerA.choiceText.replacingOccurrences(of: "\\u{2082}", with: "\u{2082}")
            let bText = question.answerB.choiceText.replacingOccurrences(of: "\\u{2082}", with: "\u{2082}")
            let cText = question.answerC.choiceText.replacingOccurrences(of: "\\u{2082}", with: "\u{2082}")
            let dText = question.answerD.choiceText.replacingOccurrences(of: "\\u{2082}", with: "\u{2082}")
            
            buttonA.setTitle(aText.replacingOccurrences(of: "\\u{2084}", with: "\u{2084}"), for: .normal)
            buttonB.setTitle(bText.replacingOccurrences(of: "\\u{2084}", with: "\u{2084}"), for: .normal)
            buttonC.setTitle(cText.replacingOccurrences(of: "\\u{2084}", with: "\u{2084}"), for: .normal)
            buttonD.setTitle(dText.replacingOccurrences(of: "\\u{2084}", with: "\u{2084}"), for: .normal)
        }
    }
    
    private func createMathLabel(_ text: String, _ button: ChoiceButton) {
        button.mathLabel.latex = text
        button.mathLabel.sizeToFit()
        button.mathLabel.textColor = UIColor.black
        button.addSubview(button.mathLabel)
    }
    
    private func renderPassage(content: Content) {
        let space = "       "
        
        let titleLabel = UILabel()
        let introLabel = UILabel()
        let mainLabel = UILabel()
        let bottomSpace = UIView(frame: CGRect(x: 0.0, y: 0.0, width: contentStackView.frame.width, height: contentStackView.frame.height*0.1))
        bottomSpace.heightAnchor.constraint(equalToConstant: contentStackView.frame.height*0.1).isActive = true
        bottomSpace.widthAnchor.constraint(equalToConstant: contentStackView.frame.width).isActive = true
        let image = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: contentStackView.frame.width*0.8, height: contentStackView.frame.width*0.8))
        let labels = content.labels
        
        if content.title != "" {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.numberOfLines = 0
            titleLabel.font = UIFont(name: "Gill Sans", size: 24)
            
            if content.storyID != "" {
                let titleString = NSMutableAttributedString()
                let attrs = [NSAttributedStringKey.foregroundColor : mint, ]
                titleString.append(NSMutableAttributedString(string: content.title + "  ", attributes:attrs))
                let attachment = NSTextAttachment()
                attachment.image = UIImage(named: "Arrow")
                attachment.bounds.origin = CGPoint(x: 0, y: -5)
                attachment.bounds.size = (UIImage(named: "Arrow")?.size)!
                titleString.append(NSAttributedString(attachment: attachment))
                titleLabel.attributedText = titleString
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openStory))
                titleLabel.isUserInteractionEnabled = true
                titleLabel.addGestureRecognizer(tapGesture)
            }
            else {
                titleLabel.text = content.title
            }
            contentStackView.addArrangedSubview(titleLabel)
        }
        if content.intro != "" {
            introLabel.translatesAutoresizingMaskIntoConstraints = false
            introLabel.numberOfLines = 0
            introLabel.font = UIFont(name: "Gill Sans", size: 16)
            introLabel.text = content.intro.replacingOccurrences(of: "\\n", with: "\n" + space)
            contentStackView.addArrangedSubview(introLabel)
        }
        if content.image != "" {
            do {
                let imageURL = URL(string: content.image)
                let data = try Data(contentsOf: imageURL!)
                image.contentMode = .scaleAspectFit
                let oldImage = UIImage(data: data)
                let oldWidth = oldImage!.size.width
                let scaleFactor = contentStackView.frame.size.width * 0.95 / oldWidth
                let cgImage = oldImage!.cgImage
                
                let width = Double(cgImage!.width) * Double(scaleFactor)
                let height = Double(cgImage!.height) * Double(scaleFactor)
                let bitsPerComponent = cgImage!.bitsPerComponent
                let bytesPerRow = cgImage!.bytesPerRow
                let colorSpace = cgImage!.colorSpace
                let bitmapInfo = cgImage!.bitmapInfo
                
                var context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue)
                if context == nil {
                    context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
                    
                }
                
                context!.interpolationQuality = .high
                UIGraphicsPushContext(context!)
                UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(width), height: CGFloat(height)), false, UIScreen.main.scale)
                oldImage?.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat(width), height: CGFloat(height))))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                image.image = newImage
                
                var ivFrame = image.frame
                ivFrame.size.height = (image.image?.size.height)!
                ivFrame.size.width = (image.image?.size.width)!
                image.frame = ivFrame
                contentStackView.addArrangedSubview(image)
            }
            catch{
                image.image = UIImage(named:"Error")
                image.contentMode = .scaleAspectFit
                contentStackView.addArrangedSubview(image)
                let errorLabel = UILabel()
                errorLabel.translatesAutoresizingMaskIntoConstraints = false
                errorLabel.numberOfLines = 0
                errorLabel.font = UIFont(name: "Gill Sans", size: 16)
                errorLabel.text = "We're having trouble loading...check your network connection."
                errorLabel.textAlignment = .center
                errorLabel.textColor = UIColor(red:1.00, green:0.39, blue:0.42, alpha:1.0)
                contentStackView.addArrangedSubview(errorLabel)
            }
        }
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.numberOfLines = 0
        mainLabel.font = UIFont(name: "Georgia", size: 16)
        
        let cArray = content.main
        var attributedString = NSMutableAttributedString()
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        if question.subject == "Writing" {
            paragraphStyle.lineSpacing = 10
        } else {
            paragraphStyle.lineSpacing = 5
        }
        
        if content.labels.count == 0 {
            var string = cArray[0].replacingOccurrences(of: "\\u{2082}", with: "\u{2082}")
            string = string.replacingOccurrences(of: "\\u{2084}", with: "\u{2084}")
            if content.useLabels {
                attributedString = NSMutableAttributedString(string: string.replacingOccurrences(of: "\\n", with: "\n"))
            } else {
                attributedString = NSMutableAttributedString(string: space + string.replacingOccurrences(of: "\\n", with: "\n" + space))
            }
        } else {
            attributedString = NSMutableAttributedString(string: space)
            if content.useLabels  {
                let iconSize = CGRect(x: 0, y: -5, width: 30, height: 30)
                let iconList = [UIImage(named: "iconA"), UIImage(named: "iconB"), UIImage(named: "iconC"), UIImage(named: "iconD")]
                
                var counter = 0
                for i in 0...cArray.count-1 {
                    var string = cArray[i].replacingOccurrences(of: "\\u{2082}", with: "\u{2082}")
                    string = string.replacingOccurrences(of: "\\u{2084}", with: "\u{2084}")
                    if labels.contains(i) {
                        let attachment = NSTextAttachment()
                        attachment.image = iconList[counter]
                        attachment.bounds = iconSize
                        attributedString.append(NSAttributedString(attachment: attachment))
                        counter += 1
                        let attrs = [NSAttributedStringKey.foregroundColor : mint]
                        attributedString.append(NSMutableAttributedString(string:string.replacingOccurrences(of: "\\n", with: "\n" + space), attributes:attrs))
                    } else {
                        attributedString.append(NSMutableAttributedString(string:string.replacingOccurrences(of: "\\n", with: "\n" + space)))
                    }
                }
            }
            else {
                for i in 0...cArray.count-1 {
                    var string = cArray[i].replacingOccurrences(of: "\\u{2082}", with: "\u{2082}")
                    string = string.replacingOccurrences(of: "\\u{2084}", with: "\u{2084}")
                    if labels.contains(i) {
                        let attrs = [NSAttributedStringKey.foregroundColor : mint, NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue] as [NSAttributedStringKey : Any]
                        attributedString.append(NSMutableAttributedString(string:string.replacingOccurrences(of: "\\n", with: "\n" + space), attributes:attrs))
                    } else {
                        attributedString.append(NSMutableAttributedString(string: string.replacingOccurrences(of: "\\n", with: "\n" + space)))
                    }
                }
            }
        }
        
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        mainLabel.attributedText = attributedString
        
        contentStackView.addArrangedSubview(mainLabel)
        contentStackView.addArrangedSubview(bottomSpace)
    }
    
    @objc func openStory(sender: UITapGestureRecognizer) {
        add(asChildViewController: makeStory)
        addChildViewController(storyController!)
    }
    
    func add(asChildViewController viewController: UIViewController) {
        viewController.view.tag = 1
        UIApplication.shared.keyWindow?.addSubview(viewController.view)
        viewController.view.frame = (navigationController?.view.bounds)!
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParentViewController: self)
    }
    
    private func renderContent(q: Question) {
        contentStackView.layoutMargins = UIEdgeInsets(top: 25, left: 25, bottom: 0, right: 25)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        renderPassage(content: q.content)
        
        if question.tag == "Analyzing Multiple Texts" {
            let separator = UIView(frame: CGRect(x: 0.0, y: 0.0, width: contentStackView.frame.width, height: 50))
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            separator.widthAnchor.constraint(equalToConstant: contentStackView.frame.width).isActive = true
            separator.backgroundColor = mint
            
            let bottomSpace = UIView(frame: CGRect(x: 0.0, y: 0.0, width: contentStackView.frame.width, height: contentStackView.frame.height*0.1))
            bottomSpace.heightAnchor.constraint(equalToConstant: contentStackView.frame.height*0.1).isActive = true
            bottomSpace.widthAnchor.constraint(equalToConstant: contentStackView.frame.width).isActive = true
            
            contentStackView.addArrangedSubview(separator)
            contentStackView.addArrangedSubview(bottomSpace)
            renderPassage(content: q.content2!)
        }
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        card.translatesAutoresizingMaskIntoConstraints = false
        
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior(items: [card])
        gravity.magnitude = 3.0
        animator.addBehavior(gravity)
        
        collision = UICollisionBehavior(items: [card])
        collision.addBoundary(withIdentifier: "center" as NSCopying, from: CGPoint(x: 0, y: view.frame.size.height*0.82), to: CGPoint(x: view.frame.size.width, y: view.frame.size.height*0.82))
        animator.addBehavior(collision)
    }
}
