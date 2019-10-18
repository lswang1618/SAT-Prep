//
//  QuestionOverlayViewController.swift
//  Video Player
//
//  Created by Lisa Wang on 4/25/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import UIKit
import AVKit
import CoreTelephony
import SwiftyGif

class QuestionOverlayViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate{
    var backingImage: UIImage?
    var question: Question?
    
    @IBOutlet weak var backingImageView: UIImageView!
    @IBOutlet weak var dimmerLayer: UIView!
    @IBOutlet weak var questionContainer: UIView!
    
    @IBOutlet weak var backingImageTrailingInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageTopInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageLeadingInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageBottomInset: NSLayoutConstraint!
    @IBOutlet weak var questionContainerTopInset: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contextLabel: UILabel!
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var cardScrollView: UIScrollView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var questionView: UIScrollView!
    @IBOutlet weak var questionImageHeight: NSLayoutConstraint!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var choiceA: ChoiceA!
    @IBOutlet weak var choiceB: ChoiceB!
    @IBOutlet weak var choiceC: ChoiceC!
    @IBOutlet weak var choiceD: ChoiceD!
    @IBOutlet weak var questionStackView: UIStackView!
    @IBOutlet weak var helpMeButton: UIButton!
    
    @IBOutlet weak var explanationContainer: UIView!
    @IBOutlet weak var explanationContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomPaddingHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomPadding: UIView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var explanationBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonAHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonBHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonCHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonDHeight: NSLayoutConstraint!
    
    let backingImageEdgeInset: CGFloat = 15.0
    let cardCornerRadius: CGFloat = 10
    var endColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
    var startColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:0.3)
    var answered = false
    var answeredCorrect = false
    var primaryDuration = 0.5
    var animateOverlay = true
    weak var explanationController: ExplanationViewController?
    var helpMe = false
    var qKatexView: UIKatexView?
    var mKatexView: UIKatexView?
    var isDailyQ = false
    var isVidQ = false
    var isNormalQ = false
    var startTime = Date()
    var videoIndex: Int?
    var screenHeight = CGFloat(0.0)
    
    var webViewLoaded = [Int : Bool]()
    var katexLoaded = [Int : Bool]()
    
    @IBAction func closeOverlay(_ sender: UIButton) {
        self.dismiss(animated: true)
        weak var parent = self.presentingViewController as? AVPlayerViewController
        if parent != nil {
            parent?.player?.pause()
            parent?.player = nil
            parent?.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backingImageView.image = backingImage
        questionContainer.layer.cornerRadius = cardCornerRadius
        questionContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        screenHeight = UIScreen.main.bounds.height
        renderQuestion(question: question!)
        
        closeButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        animateBackingImageIn()
        animateImageLayerIn()
        scrollViewHeight.constant = min(stackView.frame.size.height + 30, UIScreen.main.bounds.height*0.7)
        self.view.layoutIfNeeded()
    }
    
    func webView(_ webView: WKWebView,didFinish navigation: WKNavigation!) {
        if webView.tag == 1 {
            webViewLoaded[1] = true
            if katexLoaded[1] == true {
                self.fixLabelMathHeight(katexView: self.mKatexView!, webView: self.mKatexView!.katexWebView, size: Float(self.screenHeight * 0.0170 / 12)) {
                    self.scrollViewHeight.constant = min(self.stackView.frame.size.height + self.mKatexView!.heightConstraint.constant + 20, UIScreen.main.bounds.height*0.7)
                }
            }
        } else if webView.tag == 2 {
            webViewLoaded[2] = true
            if katexLoaded[2] == true {
                self.fixLabelMathHeight(katexView: self.qKatexView!, webView: self.qKatexView!.katexWebView, size: Float(self.screenHeight * 0.0170 / 12)) {
                }
            }
        } else if webView.tag == 3 {
            webViewLoaded[3] = true
            if katexLoaded[3] == true {
                self.fixButtonMathHeight(button: self.choiceA, webView: self.choiceA.katexView!.katexWebView, size: Float(self.screenHeight * 0.0170 / 12))
                self.buttonAHeight.constant = self.choiceA.frame.size.height
            }
        } else if webView.tag == 4 {
            webViewLoaded[4] = true
            if katexLoaded[4] == true {
                self.fixButtonMathHeight(button: self.choiceB, webView: self.choiceB.katexView!.katexWebView, size: Float(self.screenHeight * 0.0170 / 12))
                self.buttonBHeight.constant = self.choiceB.frame.size.height
            }
        } else if webView.tag == 5 {
            webViewLoaded[5] = true
            if katexLoaded[5] == true {
                self.fixButtonMathHeight(button: self.choiceC, webView: self.choiceC.katexView!.katexWebView, size: Float(self.screenHeight * 0.0170 / 12))
                self.buttonCHeight.constant = self.choiceC.frame.size.height
            }
        } else if webView.tag == 6 {
            webViewLoaded[6] = true
            if katexLoaded[6] == true {
                self.fixButtonMathHeight(button: self.choiceD, webView: self.choiceD.katexView!.katexWebView, size: Float(self.screenHeight * 0.0170 / 12))
                self.buttonDHeight.constant = self.choiceD.frame.size.height
            }
        }
    }
    
     func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if self.qKatexView != nil && self.qKatexView!.frame.size.height == 0 {
            katexLoaded[2] = true
            if webViewLoaded[2] == true {
                self.fixLabelMathHeight(katexView: self.qKatexView!, webView: self.qKatexView!.katexWebView, size: Float(self.screenHeight * 0.0170 / 12)) {
                }
            }
        }
        if self.mKatexView != nil && self.mKatexView!.frame.size.height == 0 {
            katexLoaded[1] = true
            if webViewLoaded[1] == true {
                self.fixLabelMathHeight(katexView: self.mKatexView!, webView: self.mKatexView!.katexWebView, size: Float(self.screenHeight * 0.0170 / 12)) {
                    self.scrollViewHeight.constant = min(self.stackView.frame.size.height + self.mKatexView!.heightConstraint.constant + 10, UIScreen.main.bounds.height*0.7)
                }
            }
        }
        
        if self.choiceA.katexView != nil && self.choiceA.katexView!.frame.size.height == 0 {
            katexLoaded[3] = true
            if webViewLoaded[3] == true {
                self.fixButtonMathHeight(button: self.choiceA, webView: self.choiceA.katexView!.katexWebView, size: Float(screenHeight * 0.0170 / 12))
                self.buttonAHeight.constant = self.choiceA.frame.size.height
            }
        }
        if self.choiceB.katexView != nil && self.choiceB.katexView!.frame.size.height == 0 {
            katexLoaded[4] = true
            if webViewLoaded[4] == true {
                self.fixButtonMathHeight(button: self.choiceB, webView: self.choiceB.katexView!.katexWebView, size: Float(screenHeight * 0.0170 / 12))
                self.buttonBHeight.constant = self.choiceB.frame.size.height
            }
        }
        if self.choiceC.katexView != nil && self.choiceC.katexView!.frame.size.height == 0 {
            katexLoaded[5] = true
            if webViewLoaded[5] == true {
                self.fixButtonMathHeight(button: self.choiceC, webView: self.choiceC.katexView!.katexWebView, size: Float(screenHeight * 0.0170 / 12))
                self.buttonCHeight.constant = self.choiceC.frame.size.height
            }
        }
        if self.choiceD.katexView != nil && self.choiceD.katexView!.frame.size.height == 0 {
            katexLoaded[6] = true
            if webViewLoaded[6] == true {
                self.fixButtonMathHeight(button: self.choiceD, webView: self.choiceD.katexView!.katexWebView, size: Float(screenHeight * 0.0170 / 12))
                self.buttonDHeight.constant = self.choiceD.frame.size.height
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if animateOverlay { configureImageLayerInStartPosition() }
    }
    
    func getElapsedTime() -> Int{
        let diff = NSDate().timeIntervalSince(startTime)
        return Int(ceil(diff / 60))
        
    }
    
    func handleCorrect() {
        let model = Model()
        if isDailyQ {
            model.userAnsweredDailyQ(tag: question!.tag, index: question!.index, subject: question!.subject, elapsedTime: getElapsedTime())
        } else if isVidQ{
            model.userAnsweredVideoQ(tag: question!.tag, videoIndex: videoIndex!, subject: question!.topic!, elapsedTime: getElapsedTime())
        } else if isNormalQ {
            model.userAnsweredQ(tag: question!.tag, index: question!.index, subject: question!.subject, elapsedTime: getElapsedTime()) {
                weak var parent = self.presentingViewController as? CustomTabBarViewController
                weak var homeVC = parent!.children[0] as? HomeController
                if homeVC!.galleryController?.questionOfTheDay != nil {
                    if self.question!.tag == homeVC!.galleryController?.questionOfTheDay!.tag {
                        model.getUser() { result in
                            homeVC!.user = result
                            homeVC!.setUpForUser()
                        }
                    }
                }
            }
        }
        
        if !answered {
            performSegue(withIdentifier: "explanationSegue", sender: nil)
            explanationContainer.isHidden = false
            bottomConstraint.priority = UILayoutPriority.init(rawValue: 900.0)
            explanationBottomConstraint.priority = UILayoutPriority.init(rawValue: 999.0)
            cardScrollView.scrollToView(view: explanationContainer, animated: true)
            answered = true
            answeredCorrect = true
        } else {
            cardScrollView.scrollToView(view: explanationContainer, animated: true)
        }
        explanationController?.dataSource = []
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.animateBackingImageOut()
            if self.animateOverlay {
                self.animateImageLayerOut() { _ in
                    self.dismiss(animated: false)
                }
                weak var parent = self.presentingViewController as? AVPlayerViewController
                weak var tabVC = parent?.presentingViewController as? CustomTabBarViewController
                if tabVC != nil {
                    weak var homeVC = tabVC!.children[0] as? HomeController
                    
                    var newVideoProgress = [Int]()
                    if (self.videoIndex)! >= (homeVC!.galleryController?.videoProgress.count)! {
                        newVideoProgress = [Int](repeating: 0, count: self.videoIndex! + 1)
                        for (i, v) in (homeVC!.galleryController?.videoProgress.enumerated())! {
                            newVideoProgress[i] = v
                        }
                        newVideoProgress[self.videoIndex!] = 1
                        homeVC!.galleryController?.videoProgress = newVideoProgress
                        homeVC!.galleryController?.collectionView?.reloadData()
                    } else if (homeVC!.galleryController?.videoProgress[self.videoIndex!])! < 6{
                        homeVC!.galleryController?.videoProgress[self.videoIndex!] += 1
                        homeVC!.galleryController?.collectionView?.reloadData()
                    }
                    parent!.player?.play()
                }
            } else {
                self.dismiss(animated: true)
                weak var parent = self.presentingViewController as? CustomTabBarViewController
                weak var homeVC = parent!.children[0] as? HomeController
                
                if self.isDailyQ {
                    homeVC!.galleryController?.questionOfTheDay = nil
                    homeVC!.galleryController!.pageControl?.numberOfPages -= 1
                }
                
                if self.isNormalQ || self.isDailyQ {
                    if self.question!.subject == "Reading" {
                        var badgeArray = homeVC!.tagController?.badges[0]
                        if let indexOfTarget = badgeArray?.firstIndex(where: {$0.tag == self.question!.tag}) {
                            badgeArray![indexOfTarget].update(index: self.question!.index + 1)
                            homeVC!.tagController?.badges[0] = badgeArray!
                        }
                    } else if self.question!.subject == "Math" {
                        var badgeArray = homeVC!.tagController?.badges[1]
                        if let indexOfTarget = badgeArray?.firstIndex(where: {$0.tag == self.question!.tag}) {
                            badgeArray![indexOfTarget].update(index: self.question!.index + 1)
                            homeVC!.tagController?.badges[1] = badgeArray!
                        }
                    } else {
                        var badgeArray = homeVC?.tagController?.badges[2]
                        if let indexOfTarget = badgeArray?.firstIndex(where: {$0.tag == self.question!.tag}) {
                            badgeArray![indexOfTarget].update(index: self.question!.index + 1)
                            homeVC!.tagController?.badges[2] = badgeArray!
                        }
                    }
                }
                homeVC!.user!.minutesPracticed += 1
                if homeVC!.user!.minutesPracticed > 2 {
                    if !UserDefaults.standard.bool(forKey: "feedback") {
                        UserDefaults.standard.set(true, forKey: "feedback")
                        homeVC!.requestFeedback()
                    }
                }
            }
        }
    }
    
    func handleIncorrect() {
        if !answered {
            performSegue(withIdentifier: "explanationSegue", sender: nil)
            explanationContainer.isHidden = false
            bottomConstraint.priority = UILayoutPriority.init(rawValue: 900.0)
            explanationBottomConstraint.priority = UILayoutPriority.init(rawValue: 999.0)
            answered = true
        } else {
            cardScrollView.scrollToView(view: explanationContainer, animated: true)
        }
    }
    
    func updateHeight(height: CGFloat) {
        explanationContainerHeight.constant = height
        scrollViewBottomPaddingHeight.constant = questionContainer.frame.size.height - height - 20
        cardScrollView.scrollToView(view: explanationContainer, animated: true)
    }
    
    func renderExtraPassage(content: Content) {
        let space = "       "
        
        let title2Label = UILabel()
        let intro2Label = UILabel()
        let main2Label = UILabel()
        let bottomSpace = UIView(frame: CGRect(x: 0.0, y: 0.0, width: stackView.frame.width, height: stackView.frame.height*0.1))
        bottomSpace.heightAnchor.constraint(equalToConstant: stackView.frame.height*0.1).isActive = true
        bottomSpace.widthAnchor.constraint(equalToConstant: stackView.frame.width).isActive = true
        
        if content.title != "" {
            title2Label.translatesAutoresizingMaskIntoConstraints = false
            title2Label.numberOfLines = 0
            title2Label.font = titleLabel.font.withSize(screenHeight * 0.0295)
            title2Label.text = unicodeConverter(string: content.title)
            
            stackView.addArrangedSubview(title2Label)
        }
        
        if content.intro != "" {
            intro2Label.translatesAutoresizingMaskIntoConstraints = false
            intro2Label.numberOfLines = 0
            intro2Label.font = contextLabel.font.withSize(screenHeight * 0.0170)
            intro2Label.text = unicodeConverter(string: content.intro.replacingOccurrences(of: "\\n", with: "\n" + space))
            stackView.addArrangedSubview(intro2Label)
        }
        
        if content.main.count > 0 {
            main2Label.attributedText = getMainAttributedString(content: content)
            main2Label.translatesAutoresizingMaskIntoConstraints = false
            main2Label.numberOfLines = 0
            main2Label.font = mainLabel.font.withSize(screenHeight * 0.0197)
            stackView.addArrangedSubview(main2Label)
        }
        stackView.addArrangedSubview(bottomSpace)
    }
    
    func renderQuestion(question: Question) {
        questionStackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = titleLabel.font.withSize(screenHeight * 0.0295)
        tagLabel.font = tagLabel.font.withSize(screenHeight * 0.0170)
        contextLabel.font = contextLabel.font.withSize(screenHeight * 0.0180)
        mainLabel.font = mainLabel.font.withSize(screenHeight * 0.0200)
        questionLabel.font = questionLabel.font.withSize(screenHeight * 0.0250)

        choiceA.titleLabel!.font = choiceA.titleLabel!.font.withSize(screenHeight * 0.0200)
        choiceB.titleLabel!.font = choiceB.titleLabel!.font.withSize(screenHeight * 0.0200)
        choiceC.titleLabel!.font = choiceC.titleLabel!.font.withSize(screenHeight * 0.0200)
        choiceD.titleLabel!.font = choiceD.titleLabel!.font.withSize(screenHeight * 0.0200)
        helpMeButton.titleLabel!.font = helpMeButton.titleLabel!.font.withSize(screenHeight * 0.0200)
        
        tagLabel.text = question.tag
        titleLabel.text = question.content.title
        contextLabel.text = question.content.intro
        
        if question.content.title == "" {
            stackView.spacing = 5
        }
        
        if question.text.contains("*") {
            DispatchQueue.main.async {
                self.questionLabel.isHidden = true
                self.qKatexView = self.configureMathLabel(string: question.text)
                self.qKatexView?.katexWebView.tag = 2
                self.questionStackView.insertArrangedSubview(self.qKatexView!, at: 0)
                
                self.webViewLoaded[2] = false
                self.katexLoaded[2] = false
            }
        } else {
            questionLabel.isHidden = false
            questionLabel.text = unicodeConverter(string: question.text.replacingOccurrences(of: "\\n", with: "\n"))
        }
        
        if question.content.image != "" {
            DispatchQueue.main.async {
                if question.content.image.contains(".gif") {
                    let url = URL(string: question.content.image)!
                    self.questionImageHeight.constant = self.screenHeight * 0.15
                    self.questionImage.setGifFromURL(url)
                } else {
                    let path = URL(string: question.content.image)!
                    let imageData = NSData(contentsOf: path)
                    self.questionImage.contentMode = .scaleAspectFit
                    
                    let oldImage = UIImage(data: imageData! as Data)
                    let oldWidth = oldImage!.size.width
                    let scaleFactor = self.stackView.frame.size.width / oldWidth
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
                    self.questionImage.image = newImage
                    self.questionImageHeight.constant = newImage!.size.height
                    self.questionImage.isHidden = false
                }
            }
        } else {
            questionImage.isHidden = true
        }
        
        // MATH HERE
        if question.content.main.count == 1 && question.content.main[0].contains("*") {
            mainLabel.isHidden = true
            DispatchQueue.main.async {
                self.mKatexView = self.configureMathLabel(string: question.content.main[0])
                self.mKatexView?.katexWebView.tag = 1
                self.stackView.addArrangedSubview(self.mKatexView!)
                self.webViewLoaded[1] = false
                self.katexLoaded[1] = false
            }
            if question.content.title == "" {
                stackView.spacing = 1
            }
            
        } else if question.content.main.count > 0 {
            mainLabel.isHidden = false
            mainLabel.attributedText = getMainAttributedString(content: question.content)
        } else {
            mainLabel.isHidden = true
        }
        
        if question.content2 != nil {
            let separator = UIView(frame: CGRect(x: 0.0, y: 0.0, width: stackView.frame.width, height: 50))
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            separator.widthAnchor.constraint(equalToConstant: stackView.frame.width).isActive = true
            separator.backgroundColor = UIColor.gray
            
            stackView.addArrangedSubview(separator)
            stackView.setCustomSpacing(30, after: mainLabel)
            stackView.setCustomSpacing(30, after: separator)
            
            renderExtraPassage(content: question.content2!)
        }
        
        //let height = UIScreen.main.bounds.height / 15
        choiceA.titleLabel?.numberOfLines = 0
        choiceA.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        choiceB.titleLabel?.numberOfLines = 0
        choiceB.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        choiceC.titleLabel?.numberOfLines = 0
        choiceC.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        choiceD.titleLabel?.numberOfLines = 0
        choiceD.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        choiceA.contentHorizontalAlignment = .left
        choiceB.contentHorizontalAlignment = .left
        choiceC.contentHorizontalAlignment = .left
        choiceD.contentHorizontalAlignment = .left
        
        if checkForMathButton(string: question.answerA.choiceText, button: choiceA) {
            webViewLoaded[3] = false
            katexLoaded[3] = false
            choiceA.katexView?.katexWebView.tag = 3
        }
        if checkForMathButton(string: question.answerB.choiceText, button: choiceB) {
            webViewLoaded[4] = false
            katexLoaded[4] = false
            choiceB.katexView?.katexWebView.tag = 4
        }
        if checkForMathButton(string: question.answerC.choiceText, button: choiceC) {
            webViewLoaded[5] = false
            katexLoaded[5] = false
            choiceC.katexView?.katexWebView.tag = 5
        }
        if checkForMathButton(string: question.answerD.choiceText, button: choiceD) {
            webViewLoaded[6] = false
            katexLoaded[6] = false
            choiceD.katexView?.katexWebView.tag = 6
        }
        
        let height = max(choiceA.titleLabel!.frame.size.height, choiceB.titleLabel!.frame.size.height, choiceC.titleLabel!.frame.size.height, choiceD.titleLabel!.frame.size.height, UIScreen.main.bounds.height / 15) + 10
        
        buttonAHeight.constant = height
        buttonBHeight.constant = height
        buttonCHeight.constant = height
        buttonDHeight.constant = height
        
        choiceA.clipsToBounds = true
        choiceB.clipsToBounds = true
        choiceC.clipsToBounds = true
        choiceD.clipsToBounds = true
    }
    
    func boldMovieNames(string: String) -> NSMutableAttributedString {
        if string.contains(":") == false {
            return NSMutableAttributedString(string: String(string))
        }
        
        let splitString = string.split(separator: ":")
        let attributedString = NSMutableAttributedString()
        
        let bold = [NSAttributedString.Key.font : UIFont(name: "SFProText-Medium", size: screenHeight * 0.0197) as Any] as [NSAttributedString.Key : Any]
        
        for (index, subString) in splitString.enumerated() {
            if index % 2 == 0 {
                attributedString.append(NSMutableAttributedString(string: String(subString) + ":", attributes: bold))
            } else {
                attributedString.append(NSMutableAttributedString(string: String(subString)))
            }
        }
        return attributedString
    }
    
    func getMainAttributedString(content: Content) -> NSAttributedString {
        let cArray = content.main
        var attributedString = NSMutableAttributedString()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.paragraphSpacing = screenHeight * 0.0295 * 0.5
        
        var space = "     "
        
        if content.labels.count == 0 {
            if content.movie {
                attributedString = boldMovieNames(string: unicodeConverter(string: cArray[0].replacingOccurrences(of: "\\n", with: "\n")))
            } else {
                attributedString = NSMutableAttributedString(string: unicodeConverter(string: space + cArray[0].replacingOccurrences(of: "\\n", with: "\n" + space)))
            }
        } else {
            if content.movie {
                paragraphStyle.headIndent = 0
                space = ""
            }
            
            attributedString = NSMutableAttributedString(string: space)
            var counter = 0
            let iconSize = CGRect(x: 0, y: -5, width: 30, height: 30)
            let iconList = [UIImage(named: "IconA"), UIImage(named: "IconB"), UIImage(named: "IconC"), UIImage(named: "IconD")]
            
            for i in 0...cArray.count-1 {
                let string = cArray[i]
                if content.labels.contains(i) {
                    if content.useLabels {
                        let attachment = NSTextAttachment()
                        attachment.image = iconList[counter]
                        attachment.bounds = iconSize
                        attributedString.append(NSAttributedString(attachment: attachment))
                        attributedString.append(NSMutableAttributedString(string: " "))
                        counter += 1
                    }

                    let attrs = [NSAttributedString.Key.foregroundColor : UIColor(red:0.18, green:0.77, blue:0.71, alpha:1.0), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue] as [NSAttributedString.Key : Any]
                    attributedString.append(NSMutableAttributedString(string:unicodeConverter(string: string.replacingOccurrences(of: "\\nm", with: "\n").replacingOccurrences(of: "\\n", with: "\n" + space)), attributes:attrs))
                } else {
                    if content.movie {
                        attributedString.append(boldMovieNames(string: unicodeConverter(string: string.replacingOccurrences(of: "\\nm", with: "\n").replacingOccurrences(of: "\\n", with: "\n" + space))))
                    } else {
                        attributedString.append(NSMutableAttributedString(string: unicodeConverter(string: string.replacingOccurrences(of: "\\nm", with: "\n").replacingOccurrences(of: "\\n", with: "\n" + space))))
                    }
                }
            }
        }
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        return attributedString
    }
    
    func unicodeConverter(string: String) -> String {
        var convertedString = string
        let unicode = "\\\\u\\{[a-zA-Z0-9]+\\}"
        var result = string.range(of: unicode, options: .regularExpression)
        
        while result != nil {
            let substring = convertedString[result!].dropFirst(3).dropLast()
            let unicodeHex = Int(substring, radix: 16)
            let unicodeString = Character(UnicodeScalar(unicodeHex!)!)
            convertedString = convertedString.replacingOccurrences(of: convertedString[result!], with: String(unicodeString))
            result = convertedString.range(of: unicode, options: .regularExpression)
        }
        return convertedString
    }
    
    
    func configureMathLabel(string: String) -> UIKatexView {
        let contentController = WKUserContentController()
        contentController.add(LeakAvoider(delegate: self), name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.selectionGranularity = .character
        
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.navigationDelegate = self
        let katexView = UIKatexView(string, center: CGPoint(x: 0, y:0), delimiter: "*", webView: webView)
        
        return katexView!
    }
    
    func checkForMathButton(string: String, button: ChoiceButton) -> Bool{
        if string.contains("*") {
            let contentController = WKUserContentController()
            contentController.add(LeakAvoider(delegate: self), name: "callbackHandler")
            let config = WKWebViewConfiguration()
            config.userContentController = contentController
            config.selectionGranularity = .character
            
            let webView = WKWebView(frame: CGRect.zero, configuration: config)
            webView.navigationDelegate = self
            
            let screenWidth = UIScreen.main.bounds.width
            let katexView = UIKatexView(string, center: CGPoint(x:screenWidth * 0.18, y:button.center.y), delimiter: "*", webView: webView)
            
            button.katexView = katexView
            button.addSubview(button.katexView!)
            button.katexView?.isUserInteractionEnabled = false
            return true
        } else {
            button.setTitle(unicodeConverter(string: string), for: .normal)
            button.layoutIfNeeded()
            return false
        }
    }
    
    @IBAction func selectA(_ sender: UIButton) {
        if question?.correctAnswer == 0 {
            handleCorrect()
        } else {
            handleIncorrect()
        }
    }
    
    @IBAction func selectB(_ sender: UIButton) {
        if question?.correctAnswer == 1 {
            handleCorrect()
        } else {
            handleIncorrect()
        }
    }
    
    @IBAction func selectC(_ sender: UIButton) {
        if question?.correctAnswer == 2 {
            handleCorrect()
        } else {
            handleIncorrect()
        }
    }
    
    @IBAction func selectD(_ sender: UIButton) {
        if question?.correctAnswer == 3 {
            handleCorrect()
        } else {
            handleIncorrect()
        }
    }
    @IBAction func help(_ sender: UIButton) {
        helpMe = true
        handleIncorrect()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "explanationSegue"{
            explanationController = segue.destination as? ExplanationViewController
            explanationController?.parentVC = self
            if !answeredCorrect {
                explanationController?.explanations = question!.answerSteps
            }
            if helpMe {
                explanationController?.helpMe = true
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return(false)
    }
    
    func fixLabelMathHeight(katexView: UIKatexView, webView: WKWebView, size: Float, completion: @escaping(() -> ())) {
        webView.scrollView.isScrollEnabled = false
        
        var frame = webView.frame
        frame.size.width = questionStackView.frame.size.width
        frame.size.height = 0
        frame.origin.y = 0
        webView.frame = frame
        
        insertCSSSize(into: webView, size: size) { (result, error) in
            webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                if height != nil {
                    if #available(iOS 13.0, *) {
                        frame.size.height = height as! CGFloat + 20
                    } else {
                        frame.size.height = height as! CGFloat
                    }
                    
                    webView.frame = frame
                    
                    var katexFrame = katexView.frame
                    katexFrame.size = webView.frame.size
                    katexView.frame = katexFrame
                    
                    katexView.heightConstraint = katexView.heightAnchor.constraint(equalToConstant: webView.frame.size.height)
                    katexView.heightConstraint.isActive = true
                    
                    katexView.widthConstraint = katexView.widthAnchor.constraint(equalToConstant: webView.frame.size.width)
                    katexView.widthConstraint.isActive = true
                    completion()
                }
            })
        }
    }
    
    func fixButtonMathHeight(button: ChoiceButton, webView: WKWebView, size: Float) {
        var frame = webView.frame
        frame.size.width = button.frame.size.width
        frame.size.height = 0
        frame.origin.y = 0
        webView.frame = frame
        
        insertCSSSize(into: webView, size: size) { (result, error) in
            webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                if height != nil {
                    if #available(iOS 13.0, *) {
                        frame.size.height = height as! CGFloat + 10
                    } else {
                        frame.size.height = height as! CGFloat
                    }
                    webView.frame = frame
                    
                    var katexFrame = button.katexView!.frame
                    katexFrame.size = webView.frame.size
                    button.katexView?.frame = katexFrame
                    
                    var buttonFrame = button.frame
                    buttonFrame.size.height = max(buttonFrame.size.height, webView.frame.size.height + 10)
                    button.frame = buttonFrame
                    let inset = CGFloat(18.0)
                    
                    if buttonFrame.size.height < webView.frame.size.height + 10 {
                        button.translatesAutoresizingMaskIntoConstraints = false
                        button.katexView!.center = CGPoint(x: button.katexView!.center.x, y: (buttonFrame.size.height + inset) / 2)
                        button.label.center = CGPoint(x: button.label.center.x, y: (buttonFrame.size.height + inset / 2) / 2)
                        button.shapeLayer.frame.origin = CGPoint(x: button.shapeLayer.frame.origin.x, y: buttonFrame.size.height / 2 - button.label.frame.size.height / 2)
                    } else {
                        button.katexView!.center = CGPoint(x: button.katexView!.center.x, y: buttonFrame.size.height / 2)
                    }
                    
                    self.insertCSSString(into: (button.katexView?.katexWebView!)!)
                }
                
            })
        }
    }
    
    func insertCSSString(into webView: WKWebView) {
        let cssString = "body { background-color: #f3f3f3 }"
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(jsString, completionHandler: nil)
    }
    
    func insertCSSSize(into webView: WKWebView, size: Float, completion: @escaping((Any?, Error?) -> ())) {
        let size = String(size)
        let cssString = "body { margin-left:0px; margin-right:0px; font-size:" + size + "em }"
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        
        webView.evaluateJavaScript(jsString, completionHandler: completion)
    }
    
}

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

//background image animation
extension QuestionOverlayViewController {
    
    //1.
    private func configureBackingImageInPosition(presenting: Bool) {
        let edgeInset: CGFloat = presenting ? backingImageEdgeInset : 0
        let dimmerAlpha: CGFloat = presenting ? 0.3 : 0
        let cornerRadius: CGFloat = presenting ? cardCornerRadius : 0
        
        backingImageLeadingInset.constant = edgeInset
        backingImageTrailingInset.constant = edgeInset
        let aspectRatio = backingImageView.frame.height / backingImageView.frame.width
        backingImageTopInset.constant = edgeInset * aspectRatio
        backingImageBottomInset.constant = edgeInset * aspectRatio
        //2.
        dimmerLayer.alpha = dimmerAlpha
        //3.
        backingImageView.layer.cornerRadius = cornerRadius
    }
    
    //4.
    private func animateBackingImage(presenting: Bool) {
        UIView.animate(withDuration: primaryDuration) {
            self.configureBackingImageInPosition(presenting: presenting)
            self.view.layoutIfNeeded() //IMPORTANT!
        }
    }
    
    //5.
    func animateBackingImageIn() {
        animateBackingImage(presenting: true)
    }
    
    func animateBackingImageOut() {
        animateBackingImage(presenting: false)
    }
}

extension QuestionOverlayViewController {
    
    //1.
    private var imageLayerInsetForOutPosition: CGFloat {
        let inset = UIScreen.main.bounds.height - backingImageEdgeInset
        return inset
    }
    
    //2.
    func configureImageLayerInStartPosition() {
        questionContainer.backgroundColor = startColor
        let startInset = imageLayerInsetForOutPosition
        questionContainer.layer.cornerRadius = 0
        questionContainerTopInset.constant = startInset
        view.layoutIfNeeded()
    }
    
    //3.
    func animateImageLayerIn() {
        //4.
        UIView.animate(withDuration: primaryDuration / 4.0) {
            self.questionContainer.backgroundColor = self.endColor
        }
        
        //5.
        UIView.animate(withDuration: primaryDuration, delay: 0, options: [.curveEaseIn], animations: {
            self.questionContainerTopInset.constant = 0
            self.questionContainer.layer.cornerRadius = self.cardCornerRadius
            self.view.layoutIfNeeded()
        })
    }
    
    func animateImageLayerOut(completion: @escaping ((Bool) -> Void)) {
        let endInset = imageLayerInsetForOutPosition
        
        UIView.animate(withDuration: primaryDuration / 4.0,
                       delay: primaryDuration,
                       options: [.curveEaseOut], animations: {
                        self.questionContainer.backgroundColor = self.startColor
        }, completion: { finished in
            completion(finished) //fire complete here , because this is the end of the animation
        })
        
        UIView.animate(withDuration: primaryDuration, delay: 0, options: [.curveEaseOut], animations: {
            self.questionContainerTopInset.constant = endInset
            self.questionContainer.layer.cornerRadius = 0
            self.view.layoutIfNeeded()
        })
    }
}

extension UIScrollView {
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.setContentOffset(CGPoint(x: 0, y: childStartPoint.y - 40), animated: animated)
        }
    }
    
    // Bonus: Scroll to top
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    // Bonus: Scroll to bottom
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
    
}







