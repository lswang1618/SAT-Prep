//
//  ExplanationCollectionViewCell.swift
//  Video Player
//
//  Created by Lisa Wang on 6/12/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

class ExplanationCollectionViewCell: UICollectionViewCell, WKScriptMessageHandler, WKNavigationDelegate{
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var correctStackView: UIStackView!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var correctImageView: UIImageView!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var quoteLabel: EdgeInsetLabel!
    @IBOutlet weak var choiceA: ExplanationButton!
    @IBOutlet weak var choiceB: ExplanationButton!
    @IBOutlet weak var arrowUpButton: UIButton!
    @IBOutlet weak var quoteImageView: UIImageView!
    @IBOutlet weak var quoteImageHeight: NSLayoutConstraint!
    
    weak var parentVC: ExplanationViewController?
    var qKatexView: UIKatexView?
    var eKatexView: UIKatexView?
    var loaded = [String: Bool]()
    var webViewLoaded = [String: Bool]()
    var katexLoaded = [String: Bool]()
    var totalCells = 0
    var index = 0
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calculateHeight()
        quoteLabel.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        quoteLabel.layer.addBorder(edge: UIRectEdge.left, color: UIColor.black, thickness: 4.0)
        
        if qKatexView != nil {
            qKatexView!.layer.addBorder(edge: UIRectEdge.left, color: UIColor.black, thickness: 4.0)
        }
    }
    
    override func prepareForReuse() {
        stackView.spacing = 15
        correctLabel.text = ""
        correctImageView.image = UIImage()
        arrowUpButton.isHidden = true
        correctStackView.isHidden = true
        explanationLabel.isHidden = false
        quoteLabel.isHidden = false
        quoteLabel.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        quoteImageView.isHidden = true
        choiceA.isHidden = false
        choiceB.isHidden = false
        explanationLabel.text = ""
        quoteLabel.text = ""
        choiceA.setTitle("", for: .normal)
        choiceB.setTitle("", for: .normal)
        
        if qKatexView != nil {
            stackView.removeArrangedSubview(qKatexView!)
            qKatexView!.removeFromSuperview()
        }
        if eKatexView != nil {
            stackView.removeArrangedSubview(eKatexView!)
            eKatexView!.removeFromSuperview()
        }
        if choiceA.katexView != nil {
            choiceA.katexView?.removeFromSuperview()
            choiceA.heightConstraint?.isActive = false
        }
        if choiceB.katexView != nil {
            choiceB.katexView?.removeFromSuperview()
            choiceB.heightConstraint?.isActive = false
        }
    }
    
    func calculateHeight() {
        if index == totalCells - 1 {
            var newHeight = CGFloat(0.0)
            for view in stackView.subviews {
                if view.isHidden == false {
                    print(view)
                }
            }
            if correctStackView.isHidden == false {
                newHeight += correctStackView.frame.size.height
            }
            
            if explanationLabel.isHidden == false {
                newHeight += explanationLabel.frame.size.height
            }
            
            if quoteLabel.isHidden == false {
                newHeight += quoteLabel.frame.size.height
            }
            
            if eKatexView != nil {
                newHeight += eKatexView!.frame.size.height
            }
            
            if qKatexView != nil {
                newHeight += qKatexView!.frame.size.height
            }
            
            if choiceA.isHidden == false {
                newHeight += max(choiceA.intrinsicContentSize.height, choiceA.frame.size.height) + max(choiceB.intrinsicContentSize.height, choiceB.frame.size.height)
            }
            
            if quoteImageView.isHidden == false {
                newHeight += quoteImageHeight!.constant
            }
            
            parentVC?.newHeight = newHeight + 150
            parentVC?.updateHeight()
        }
    }
    
    func webView(_ webView: WKWebView,didFinish navigation: WKNavigation!) {
        if webView.tag == 1 {
            webViewLoaded["eKatexView"] = true
            if katexLoaded["eKatexView"] == true {
                adjustHeight(katexView: eKatexView!, webView: eKatexView!.katexWebView, identifier: "eKatexView", size: Float(UIScreen.main.bounds.height * 0.016 / 12))
            }
        } else if webView.tag == 2 {
            webViewLoaded["qKatexView"] = true
            if katexLoaded["qKatexView"] == true {
                adjustHeight(katexView: qKatexView!, webView: qKatexView!.katexWebView, identifier: "qKatexView", size: Float(UIScreen.main.bounds.height * 0.020 / 12))
            }
        } else if webView.tag == 3 {
            webViewLoaded["aKatexView"] = true
            if katexLoaded["aKatexView"] == true {
                adjustButtonHeight(button: choiceA, identifier: "aKatexView", size: Float(UIScreen.main.bounds.height * 0.016 / 12))
            }
        } else if webView.tag == 4 {
            webViewLoaded["bKatexView"] = true
            if katexLoaded["bKatexView"] == true {
                adjustButtonHeight(button: choiceB, identifier: "bKatexView", size: Float(UIScreen.main.bounds.height * 0.016 / 12))
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if eKatexView != nil && eKatexView!.frame.size.height == 0 {
            katexLoaded["eKatexView"] = true
            userContentController.removeScriptMessageHandler(forName: "callbackHandler")
            if webViewLoaded["eKatexView"] == true {
                adjustHeight(katexView: eKatexView!, webView: eKatexView!.katexWebView, identifier: "eKatexView", size: Float(UIScreen.main.bounds.height * 0.0160 / 12))
            }
        }
        if qKatexView != nil && qKatexView!.frame.size.height == 0 {
            katexLoaded["qKatexView"] = true
            userContentController.removeScriptMessageHandler(forName: "callbackHandler")
            if webViewLoaded["qKatexView"] == true {
                adjustHeight(katexView: qKatexView!, webView: qKatexView!.katexWebView, identifier: "qKatexView", size: Float(UIScreen.main.bounds.height * 0.020 / 12))
            }
        }
        
        if choiceA.katexView != nil && choiceA.katexView!.frame.size.height == 0 {
            katexLoaded["aKatexView"] = true
            userContentController.removeScriptMessageHandler(forName: "callbackHandler")
            if webViewLoaded["aKatexView"] == true {
                adjustButtonHeight(button: choiceA, identifier: "aKatexView", size: Float(UIScreen.main.bounds.height * 0.016 / 12))
            }
        }
        if choiceB.katexView != nil && choiceB.katexView!.frame.size.height == 0 {
            katexLoaded["bKatexView"] = true
            userContentController.removeScriptMessageHandler(forName: "callbackHandler")
            if webViewLoaded["bKatexView"] == true {
                adjustButtonHeight(button: choiceB, identifier: "bKatexView", size: Float(UIScreen.main.bounds.height * 0.016 / 12))
            }
        }
    }
    
    func adjustButtonHeight(button: ExplanationButton, identifier: String, size: Float) {
        let webView = button.katexView!.katexWebView
        webView!.scrollView.isScrollEnabled = false

        var frame = webView!.frame
        frame.size.width = button.frame.size.width
        frame.size.height = 0
        frame.origin.y = 0
        webView!.frame = frame
        
        self.insertCSSSize(into: webView!, size: size, identifier: identifier) { (result, error) in
            webView!.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (h, error) in
                if h != nil {
                    let height = h as! CGFloat
                    
                    if height > 10 {
                        if #available(iOS 13.0, *) {
                            frame.size.height = (webView?.scrollView.contentSize.height)!
                        } else {
                            frame.size.height = height
                        }
                        
                        frame.size.width = button.frame.size.width
                        webView!.frame = frame
                        
                        var katexFrame = button.katexView!.frame
                        katexFrame.size = webView!.frame.size
                        button.katexView?.frame = katexFrame
                        
                        var buttonFrame = button.frame
                        buttonFrame.size = webView!.frame.size
                        button.frame = buttonFrame
                        
                        button.translatesAutoresizingMaskIntoConstraints = false
                        
                        if button.heightConstraint != nil {
                            button.heightConstraint?.isActive = false
                        }
                        
                        button.heightConstraint = button.heightAnchor.constraint(equalToConstant:katexFrame.size.height)
                        button.heightConstraint?.isActive = true
                        button.katexView!.center = CGPoint(x: button.katexView!.center.x, y: katexFrame.size.height / 2)
                        
                        self.insertCSSString(into: (button.katexView?.katexWebView!)!)
                        self.loaded[identifier] = true
                        
                        for (_, status) in self.loaded {
                            if !status {
                                return
                            }
                        }
                        
                        self.calculateHeight()
                    }
                }
            })
        }
    }
    
    func adjustHeight(katexView: UIKatexView, webView: WKWebView, identifier: String, size: Float) {
        let webView = katexView.katexWebView
        webView!.scrollView.isScrollEnabled = false
        
        var frame = webView!.frame
        frame.size.width = stackView.frame.size.width
        frame.size.height = 1
        frame.origin.y = 0
        webView!.frame = frame
        
        self.insertCSSSize(into: webView!, size: size, identifier: identifier) { (result, error) in
            webView!.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                if height != nil {
                    frame.size.height = (height as! CGFloat) + 10
                    webView!.frame = frame
                    self.fixMathHeight(katexView: katexView, webView: webView!)
                    
                    if identifier == "qKatexView" {
                        self.qKatexView!.layer.addBorder(edge: UIRectEdge.left, color: UIColor.black, thickness: 4.0)
                    }
                    self.loaded[identifier] = true
                    
                    for (_, status) in self.loaded {
                        if !status {
                            return
                        }
                    }
                    self.calculateHeight()
                }
            })
        }
    }
    
    func fixMathHeight(katexView: UIKatexView, webView: WKWebView) {
        var katexFrame = katexView.frame
        
        katexFrame.size = webView.frame.size
        katexView.frame = katexFrame
        
        if katexView.heightConstraint != nil {
            katexView.heightConstraint.isActive = false
            katexView.widthConstraint.isActive = false
        }
        katexView.heightConstraint = katexView.heightAnchor.constraint(equalToConstant: webView.frame.size.height)
        katexView.heightConstraint.isActive = true
        
        katexView.widthConstraint = katexView.widthAnchor.constraint(equalToConstant: webView.frame.size.width)
        katexView.widthConstraint.isActive = true
    }
    
    func insertCSSString(into webView: WKWebView) {
        let cssString = "body { background-color: #f3f3f3 }"
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(jsString, completionHandler: nil)
    }
    
    func insertCSSSize(into webView: WKWebView, size: Float, identifier: String, completion: @escaping((Any?, Error?) -> ())) {
        let size = String(size)
        let cssString = "body { margin-top: 5px; font-size:" + size + "em }"
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        
        webView.evaluateJavaScript(jsString, completionHandler: completion)
    }
    
    func prepImage(newImage: UIImage) {
        quoteImageView.contentMode = .scaleAspectFit
        quoteImageView.image = newImage
        quoteImageHeight.constant = newImage.size.height + 20
        quoteImageView.layoutIfNeeded()
        self.loaded["qImageView"] = true
        
        for (_, status) in self.loaded {
            if !status {
                return
            }
        }
        self.calculateHeight()
    }
}
