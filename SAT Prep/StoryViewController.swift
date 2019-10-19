//
//  StoryViewController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 9/29/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class StoryViewController: UIViewController {
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var storyText: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet var fullView: UIView!
    @IBOutlet weak var actionLink: UITextView!
    
    var currentIndex = 0
    var storyID: String?
    var story: Story?
    var pages = [Page]()
    var model: Model?
    var progressBars = [UIProgressView]()
    var barTask: DispatchWorkItem?
    var nextTask: DispatchWorkItem?
    
    let mint = UIColor(red:0.00, green:0.58, blue:0.74, alpha:1.0)
    
    override func viewDidLoad() {
        storyImage.isUserInteractionEnabled = true
        bottomView.isUserInteractionEnabled = true
        fullView.isUserInteractionEnabled = true
        
        model = Model()
        model?.getStory(id: storyID!) {[unowned self] s in
            self.story = s
            self.pages = s.pages
            self.renderProgress(count: CGFloat(self.pages.count))
            self.renderPage(page: self.pages[0], count: 0)
        }
        
        Analytics.logEvent("story", parameters: [
            "id": storyID ?? ""
        ])
    }
    
    func renderProgress(count: CGFloat) {
        let width = view.frame.size.width - 20
        for i in stride(from: 0, to: count, by: 1) {
            let progressView = UIProgressView(progressViewStyle: .bar)
            progressView.frame = CGRect(x: CGFloat(i) * width/count + 5 * CGFloat(i), y:view.frame.size.height*0.06, width: width/count, height: 50)
            progressView.setProgress(0, animated: false)
            progressView.trackTintColor = UIColor.gray
            progressView.tintColor = UIColor.white
            view.addSubview(progressView)
            progressBars.append(progressView)
        }
    }
    
    func renderPage(page: Page, count: Int) {
        do {
            let imageURL = URL(string: page.image)
            let data = try Data(contentsOf: imageURL!)
            storyImage.image = UIImage(data: data)
            storyImage.contentMode = .scaleAspectFill
            
            storyTitle.text = page.title
            storyTitle.font = UIFont(name: "Gill Sans", size: view.frame.size.height*0.032)
            
            storyText.text = page.text
            storyText.font = UIFont(name: "Georgia", size: view.frame.size.height*0.022)
            
            let linkText = page.linkText.replacingOccurrences(of: "\\u{1F3A7}", with: "\u{1F3A7}").replacingOccurrences(of: "\\u{1F4FA}", with: "\u{1F4FA}").replacingOccurrences(of: "\\u{1F4D9}", with: "\u{1F4D9}")
            let attributedString = NSMutableAttributedString(string: linkText)
            let linkRange = (attributedString.string as NSString).range(of: linkText)
            attributedString.addAttribute(NSAttributedStringKey.link, value: page.link, range: linkRange)
            let linkAttributes: [String : Any] = [
                NSAttributedStringKey.foregroundColor.rawValue: mint,
                NSAttributedStringKey.font.rawValue: UIFont(name: "Gill Sans", size: view.frame.size.height*0.02)
            ]
            let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: view.frame.size.height*0.02)]
            
            attributedString.addAttributes(boldFontAttribute, range: linkRange)
            actionLink.linkTextAttributes = linkAttributes
            actionLink.attributedText = attributedString
            actionLink.textAlignment = .right
            
            startProgress()
        }
        catch{
            print(error)
        }
    }
    
    func startProgress() {
        barTask = DispatchWorkItem {
            UIView.animate(withDuration: 10, animations: { [unowned self] () -> Void in
                self.progressBars[self.currentIndex].setProgress(1.0, animated: true)
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: barTask!)
        
        nextTask = DispatchWorkItem {
            if self.currentIndex < self.pages.count - 1 {
                self.currentIndex += 1
                self.renderPage(page: self.pages[self.currentIndex], count: self.currentIndex)
            } else {
                self.removeFromParentViewController()
                UIApplication.shared.keyWindow?.viewWithTag(1)?.removeFromSuperview()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: nextTask!)
    }
    
    @IBAction func tap(recognizer:UITapGestureRecognizer) {
        
        barTask?.cancel()
        nextTask?.cancel()
        
        if recognizer.location(in: view).x < view.frame.size.width / 3 {
            if currentIndex == 0 {
                progressBars[currentIndex].setProgress(0, animated: false)
                startProgress()
            }
            else {
                progressBars[currentIndex].setProgress(0, animated: false)
                progressBars[currentIndex-1].setProgress(0, animated: false)
                currentIndex -= 1
                renderPage(page: pages[currentIndex], count: currentIndex)
            }
        } else {
            if currentIndex < pages.count - 1 {
                progressBars[currentIndex].layer.sublayers?.forEach { $0.removeAllAnimations() }
                progressBars[currentIndex].setProgress(1.0, animated: false)
                currentIndex += 1
                renderPage(page: pages[currentIndex], count: currentIndex)
            } else {
                self.removeFromParentViewController()
                UIApplication.shared.keyWindow?.viewWithTag(1)?.removeFromSuperview()
            }
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        barTask?.cancel()
        nextTask?.cancel()
        self.removeFromParentViewController()
        UIApplication.shared.keyWindow?.viewWithTag(1)?.removeFromSuperview()
    }
}

