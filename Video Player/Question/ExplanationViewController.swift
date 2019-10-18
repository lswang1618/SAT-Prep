//
//  ExplanationViewController.swift
//  Video Player
//
//  Created by Lisa Wang on 6/11/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class ExplanationViewController: SwipeCollectionViewController, WKNavigationDelegate {
    
    var dataSource = Array<Explanation>() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var explanations = Array<Explanation>()
    var totalCount = 0
    weak var parentVC: QuestionOverlayViewController?
    var oldHeight = CGFloat(0.0)
    var newHeight = CGFloat(0.0)
    var images = [String : UIImage]()
    
    var loadedAll = false
    var helpMe = false
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(dataSource.count, 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "explanationCell", for: indexPath) as! ExplanationCollectionViewCell
        let correctLabel = cell.viewWithTag(80) as! UILabel
        let correctImageView = cell.viewWithTag(81) as! UIImageView
        let correctStackView = cell.viewWithTag(82) as! UIStackView
        let stackView = cell.viewWithTag(99) as! UIStackView
        let explanationLabel = cell.viewWithTag(100) as! EdgeInsetLabel
        let quoteLabel = cell.viewWithTag(101) as! EdgeInsetLabel
        let quoteImageView = cell.viewWithTag(10) as! UIImageView
        let choiceA = cell.viewWithTag(102) as! ExplanationButton
        let choiceB = cell.viewWithTag(103) as! ExplanationButton
        let arrowUp = cell.viewWithTag(104) as! UIButton
        
        let index = (indexPath as IndexPath).item
        let screenHeight = UIScreen.main.bounds.height
        var loaded = [String: Bool]()
        if dataSource.count == 0 {
            correctStackView.isHidden = false
            correctLabel.text = "Correct!"
            correctLabel.font = UIFont(name: "SFProText-Black", size: screenHeight*0.03)
            correctLabel.textColor = UIColor(red:0.04, green:0.87, blue:0.78, alpha:1.0)
            correctImageView.isHidden = true
            explanationLabel.isHidden = true
            quoteLabel.isHidden = true
            choiceA.isHidden = true
            choiceB.isHidden = true
            
            startConfetti(cell: cell)
            
            let animationView = AnimationView(name: "check_animation")
            animationView.frame = CGRect(x:0, y:0, width: cell.frame.size.width, height: cell.frame.size.width)
            animationView.center.x = cell.center.x
            animationView.center.y = cell.center.y*0.8
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.animationSpeed = 0.5
            stackView.insertArrangedSubview(animationView, at: 0)
            stackView.spacing = 0.0
            
            newHeight = (correctStackView.frame.size.height + animationView.frame.size.height) * 1.5
            updateHeight()
            animationView.play()
            
            return(cell)
        }
        
        if index == 0 && !helpMe{
            correctStackView.isHidden = false
            correctLabel.font = UIFont(name: "SFProText-Black", size: screenHeight*0.02)
            correctLabel.text = "Not quite...  "
            correctImageView.image = UIImage(named: "Monkey")
        }
        
        let explanation = dataSource[index]
        
        if explanation.explanationText != "" {
            if explanation.explanationText.contains("*") {
                explanationLabel.isHidden = true
                
                let eKatexView = checkForMathLabel(string: explanation.explanationText, cell: cell)
                eKatexView.katexWebView.tag = 1
                
                cell.eKatexView = eKatexView
                stackView.insertArrangedSubview(eKatexView, at: 1)
                eKatexView.translatesAutoresizingMaskIntoConstraints = false
                loaded["eKatexView"] = false
            } else {
                explanationLabel.isHidden = false
                explanationLabel.font = explanationLabel.font.withSize(UIScreen.main.bounds.height * 0.021)
                explanationLabel.text = unicodeConverter(string: explanation.explanationText.replacingOccurrences(of: "\\n", with: "\n"))
            }
        } else {
            explanationLabel.isHidden = true
        }
        
        if explanation.quote != "" {
            if explanation.quote.contains("https") {
                quoteImageView.isHidden = false
                quoteLabel.isHidden = true
                loaded["qImageView"] = false
            }
            else if explanation.quote.contains("*") {
                quoteLabel.isHidden = true
                
                let qKatexView = checkForMathLabel(string: explanation.quote, cell: cell)
                qKatexView.katexWebView.tag = 2
                
                cell.qKatexView = qKatexView
                stackView.insertArrangedSubview(qKatexView, at: 2)
                qKatexView.translatesAutoresizingMaskIntoConstraints = false
                loaded["qKatexView"] = false
            } else {
                quoteLabel.isHidden = false
                quoteLabel.font = quoteLabel.font.withSize(UIScreen.main.bounds.height * 0.021)
                quoteLabel.text = unicodeConverter(string: explanation.quote.replacingOccurrences(of: "\\n", with: "\n"))
            }
        } else {
            quoteLabel.isHidden = true
        }
        
        if index < totalCount - 1 {
            if checkForMathButton(string: explanation.choiceA, button: choiceA, cell: cell) { loaded["aKatexView"] = false
                choiceA.katexView?.katexWebView.tag = 3
            }
            if checkForMathButton(string: explanation.choiceB, button: choiceB, cell: cell) { loaded["bKatexView"] = false
                choiceB.katexView?.katexWebView.tag = 4
            }
            
            choiceA.correctChoice = explanation.correctChoice
            choiceB.correctChoice = explanation.correctChoice
            choiceA.addTarget(self, action: #selector(self.selectChoiceA(_:)), for: UIControl.Event.touchUpInside)
            choiceB.addTarget(self, action: #selector(self.selectChoiceB(_:)), for: UIControl.Event.touchUpInside)
            arrowUp.isHidden = true
        } else {
            choiceA.isHidden = true
            choiceB.isHidden = true
            
            if (parentVC?.question!.subject)! == "Math" {
                arrowUp.setImage(UIImage(named: "Orange Arrow"), for: .normal)
            } else if (parentVC?.question!.subject)! == "Writing" {
                arrowUp.setImage(UIImage(named: "Blue Arrow"), for: .normal)
            } else if (parentVC?.question!.subject)! == "Reading" {
                arrowUp.setImage(UIImage(named: "Green Arrow"), for: .normal)
            }
            
            arrowUp.isHidden = false
            arrowUp.addTarget(self, action: #selector(self.scrollUp(_:)), for: UIControl.Event.touchUpInside)
        }
        cell.loaded = loaded
        cell.webViewLoaded = loaded
        cell.katexLoaded = loaded
        
        cell.totalCells = dataSource.count
        cell.index = index
        
        if explanation.quote.contains("https") {
            DispatchQueue.global(qos: .userInteractive).async {
                self.getImage(path: explanation.quote, cell: cell)
            }
        }
        
        if quoteImageView.isHidden != true {
            stackView.setCustomSpacing(40, after: quoteImageView)
        } else if quoteLabel.isHidden != true {
            stackView.setCustomSpacing(40, after: quoteLabel)
        } else if cell.qKatexView?.isHidden != nil {
            stackView.setCustomSpacing(40, after: cell.qKatexView!)
        } else if explanationLabel.isHidden != true {
            stackView.setCustomSpacing(40, after: explanationLabel)
        } else {
            stackView.setCustomSpacing(40, after: cell.eKatexView!)
        }
        
        return(cell)
    }
    
    func getImage(path: String, cell: ExplanationCollectionViewCell){
        if images[path] != nil {
            DispatchQueue.main.async {
                cell.prepImage(newImage: self.images[path]!)
            }
            return
        }
        
        let url = URL(string: path)
        let imageData = NSData(contentsOf: url!)
        
        let oldImage = UIImage(data: imageData! as Data)
        let oldWidth = oldImage!.size.width
        
        let scaleFactor = UIScreen.main.bounds.width * 0.7 / oldWidth
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
        
        images[path] = newImage
        DispatchQueue.main.async {
            cell.prepImage(newImage: newImage!)
        }
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
    
    func checkForMathLabel(string: String, cell: ExplanationCollectionViewCell) -> UIKatexView {
        let contentController = WKUserContentController()
        contentController.add(LeakAvoider(delegate:cell), name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.navigationDelegate = cell
        let katexView = UIKatexView(string, center: CGPoint(x: 0, y:0), delimiter: "*", webView: webView)
        
        return katexView!
    }
    
    func checkForMathButton(string: String, button: ExplanationButton, cell: ExplanationCollectionViewCell) -> Bool {
        if string.contains("*") {
            let contentController = WKUserContentController()
            contentController.add(LeakAvoider(delegate:cell), name: "callbackHandler")
            let config = WKWebViewConfiguration()
            config.userContentController = contentController
            config.selectionGranularity = .character
            let webView = WKWebView(frame: CGRect.zero, configuration: config)
            webView.navigationDelegate = cell
            
            let katexView = UIKatexView(string, center: CGPoint(x:0, y:0), delimiter: "*", webView: webView)
            button.katexView = katexView
            button.addSubview(button.katexView!)
            
            button.katexView?.isUserInteractionEnabled = false
            return(true)
        } else {
            button.titleLabel?.font = button.titleLabel!.font.withSize(UIScreen.main.bounds.height * 0.021)
            button.setTitle(unicodeConverter(string: string), for: .normal)
            return(false)
        }
    }
    
    func startConfetti(cell: UICollectionViewCell) {
        let emitter = CAEmitterLayer()
        let colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
                      UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
                      UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
                      UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
                      UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        emitter.emitterPosition = CGPoint(x: view.frame.size.width / 1.5, y: 0)
        emitter.emitterShape = CAEmitterLayerEmitterShape.line
        emitter.emitterSize = CGSize(width: cell.frame.size.width, height: 1)
        
        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color: color))
        }
        
        emitter.emitterCells = cells
        cell.layer.addSublayer(emitter)
        
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
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let collectionViewCell = cell as! ExplanationCollectionViewCell
        collectionViewCell.parentVC = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if explanations.count > 0 {
            totalCount = explanations.count
            dataSource.append(explanations[0])
            explanations.removeFirst()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureCollectionViewLayoutItemSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        collectionViewLayout.collectionView!.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    func updateHeight() {
        if newHeight > oldHeight && !loadedAll{
            parentVC?.updateHeight(height: newHeight)
            oldHeight = newHeight
            
            if explanations.count == 0 && dataSource.count > 1{
                loadedAll = true
            }
        }
    }
    
    private func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = collectionViewLayout.collectionView!.frame.size.width * 0.04
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        collectionViewFlowLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.size.width*0.92, height: collectionViewLayout.collectionView!.frame.size.height)
        
    }
    
    @objc func selectChoiceA(_ sender: ExplanationButton) {
        if sender.correctChoice == 0 {
            if explanations.count > 0 && dataSource.count - 1 == currentIndex{
                dataSource.append(explanations[0])
                explanations.removeFirst()
                collectionViewLayout.collectionView!.scrollToItem(at: IndexPath(row: dataSource.count - 1, section: 0), at: .centeredHorizontally, animated: true)
                parentVC!.cardScrollView.scrollToView(view: parentVC!.explanationContainer, animated: true)
                currentIndex = currentIndex + 1
            } else if dataSource.count - 1 != currentIndex{
                collectionViewLayout.collectionView!.scrollToItem(at: IndexPath(row: currentIndex + 1, section: 0), at: .centeredHorizontally, animated: true)
                parentVC!.cardScrollView.scrollToView(view: parentVC!.explanationContainer, animated: true)
                currentIndex = currentIndex + 1
            }
        } else {
            shake(button: sender, values: [-12.0, 12.0, -12.0, 12.0, -6.0, 6.0, -3.0, 3.0, 0.0])
        }
    }
    
    @objc func selectChoiceB(_ sender: ExplanationButton) {
        if sender.correctChoice == 1 {
            if explanations.count > 0 && dataSource.count - 1 == currentIndex{
                dataSource.append(explanations[0])
                explanations.removeFirst()
                collectionViewLayout.collectionView!.scrollToItem(at: IndexPath(row: dataSource.count - 1, section: 0), at: .centeredHorizontally, animated: true)
                parentVC!.cardScrollView.scrollToView(view: parentVC!.explanationContainer, animated: true)
                currentIndex = currentIndex + 1
            } else if dataSource.count - 1 != currentIndex{
                collectionViewLayout.collectionView!.scrollToItem(at: IndexPath(row: currentIndex + 1, section: 0), at: .centeredHorizontally, animated: true)
                parentVC!.cardScrollView.scrollToView(view: parentVC!.explanationContainer, animated: true)
                currentIndex = currentIndex + 1
            }
        } else {
            shake(button: sender, values: [-12.0, 12.0, -12.0, 12.0, -6.0, 6.0, -3.0, 3.0, 0.0])
        }
    }
    
    @objc func scrollUp(_ sender: UIButton) {
        parentVC?.cardScrollView.scrollToView(view: parentVC!.questionView, animated: true)
    }
    
    func shake(button: UIButton, duration: TimeInterval = 0.5, values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        
        // Swift 4.1 and below
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        animation.duration = duration // You can set fix duration
        animation.values = values  // You can set fix values here also
        button.layer.add(animation, forKey: "shake")
    }
}
