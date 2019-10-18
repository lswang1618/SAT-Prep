//
//  IBExtensions.swift
//  Video Player
//
//  Created by Lisa Wang on 6/9/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class EdgeInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    //var katexView = UIKatexView("", center: CGPoint(x: 0, y: 0))
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //katexView?.center = CGPoint(x: rect.size.width / 2, y: rect.size.width / 2)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
//    override func layoutSubviews() {
//        if (katexView!.frame.size.height > 0) {
//            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.katexView!.frame.size.height)
//        }
//    }
}

extension EdgeInsetLabel {
    @IBInspectable
    var leftTextInset: CGFloat {
        set { textInsets.left = newValue }
        get { return textInsets.left }
    }
    
    @IBInspectable
    var rightTextInset: CGFloat {
        set { textInsets.right = newValue }
        get { return textInsets.right }
    }
    
    @IBInspectable
    var topTextInset: CGFloat {
        set { textInsets.top = newValue }
        get { return textInsets.top }
    }
    
    @IBInspectable
    var bottomTextInset: CGFloat {
        set { textInsets.bottom = newValue }
        get { return textInsets.bottom }
    }
}

class ChoiceButton: MathButton {
    
    var buttonView = UIView()
    var label = UILabel()
    var shapeLayer = CAShapeLayer()
    
    override open var intrinsicContentSize: CGSize {
        let width =  (titleLabel?.intrinsicContentSize.width)!
        let height = (titleLabel?.intrinsicContentSize.height)!
        let size = CGSize(width: width, height: height+10)
        
        return size
    }
    
    override func draw(_ rect: CGRect) {
        buttonView.removeFromSuperview()
        shapeLayer.path = UIBezierPath(ovalIn: CGRect(x: 5, y: rect.size.height * 0.1, width: rect.size.height * 0.8, height: rect.size.height * 0.8)).cgPath
        shapeLayer.fillColor = UIColor(red:0.86, green:0.89, blue:0.93, alpha:1.0).cgColor
        
        buttonView = UIView()
        buttonView.layer.addSublayer(shapeLayer)
        buttonView.isUserInteractionEnabled = false
        
        label = UILabel(frame: CGRect(x: 5, y: rect.size.height * 0.1, width: rect.size.height * 0.8, height: rect.size.height * 0.8))
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.darkGray
        
        label.isUserInteractionEnabled = false
        
        titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? 0
        titleEdgeInsets = UIEdgeInsets(top: 0, left: (rect.size.height) * 0.95, bottom:0, right:5)
        titleLabel?.textAlignment = NSTextAlignment.left
        setTitleColor(UIColor.gray, for: .disabled)
    }
}

class ChoiceA: ChoiceButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        label.text = "A"
        buttonView.addSubview(label)
        self.addSubview(buttonView)
    }
}

class ChoiceB: ChoiceButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        label.text = "B"
        buttonView.addSubview(label)
        self.addSubview(buttonView)
    }
}

class ChoiceC: ChoiceButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        label.text = "C"
        buttonView.addSubview(label)
        self.addSubview(buttonView)
    }
}

class ChoiceD: ChoiceButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        label.text = "D"
        buttonView.addSubview(label)
        self.addSubview(buttonView)
    }
}

class ExplanationButton: MathButton {
    var correctChoice: Int = 0
    
    override func draw(_ rect: CGRect) {
        self.titleEdgeInsets = UIEdgeInsets(top: 15.0, left: 10, bottom: 15.0, right: 10.0)
    }
    
    override open var intrinsicContentSize: CGSize {
        let size = CGSize(width: (self.frame.size.width), height: (titleLabel?.intrinsicContentSize.height)! + 20)
        return size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? 0
        super.layoutSubviews()
    }
}

class MathButton: UIButton {
    var katexView: UIKatexView?
    var heightConstraint: NSLayoutConstraint?
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = .byWordWrapping
    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: UIScreen.main.bounds.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat, widthPercent: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width * widthPercent, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

class IntrinsicTableView: UITableView {
    
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

class SegueFromRight: UIStoryboardSegue {
    override func perform()
        {
            let src = self.source as UIViewController
            let dst = self.destination as UIViewController
            
            src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
            dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
            
            UIView.animate(withDuration: 0.25,
                                       delay: 0.0,
                                       options: UIView.AnimationOptions.curveEaseInOut,
                                       animations: {
                                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            },
                                       completion: { finished in
                                        src.present(dst, animated: false, completion: nil)
            }
        )
    }
}

class SegueFromTop: UIStoryboardSegue {
    override func perform() {
        // get views
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        
        // get screen height
        let screenHeight = UIScreen.main.bounds.size.height
        dst.view.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
        
        // animate
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y:0)
            },
                       completion: { finished in src.present(dst, animated: false, completion: nil)
            }
        )
    }
}

class OnboardingTopicButton: UIButton {
    var selectedColor: UIColor?
    
    override open var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? selectedColor : UIColor.white
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            setTitleColor(UIColor.white, for: .highlighted)
        }
    }
}

