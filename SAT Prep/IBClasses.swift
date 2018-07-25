//
//  IBClasses.swift
//  SAT Prep
//
//  Created by Lisa Wang on 5/29/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import iosMath

@IBDesignable
class EdgeInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    }
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

@IBDesignable
class RoundedCornerView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var borderWidth: CGFloat = 0
    private var customBackgroundColor = UIColor.white
    override var backgroundColor: UIColor?{
        didSet {
            customBackgroundColor = backgroundColor!
            super.backgroundColor = UIColor.clear
        }
    }
    
    func setup() {
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.5
        super.backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func draw(_ rect: CGRect) {
        customBackgroundColor.setFill()
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).fill()
        
        let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - borderWidth/2)
        borderColor.setStroke()
        borderPath.lineWidth = borderWidth
        borderPath.stroke()
    }
}

class MultiLineButton: UIButton {
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    private func commonInit() {
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = .byWordWrapping
    }
    
    // MARK: - Overrides
    
    override open var intrinsicContentSize: CGSize {
        let size = CGSize(width: (titleLabel?.intrinsicContentSize.width)!, height: (titleLabel?.intrinsicContentSize.height)! + 20)
        return size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? 0
        super.layoutSubviews()
    }
    
}

class ChoiceButton: UIButton {
    
    var buttonView = UIView()
    var label = UILabel()
    var mathLabel = MTMathUILabel()
    var shapeLayer = CAShapeLayer()
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = .byWordWrapping
    }
    
    override open var intrinsicContentSize: CGSize {
        let width =  max((titleLabel?.intrinsicContentSize.width)!, mathLabel.intrinsicContentSize.width)
        let height = max((titleLabel?.intrinsicContentSize.height)!, mathLabel.intrinsicContentSize.height)
        let size = CGSize(width: width, height: height+10)
        
        return size
    }
    
    override func draw(_ rect: CGRect) {
        buttonView.removeFromSuperview()
        shapeLayer.path = UIBezierPath(ovalIn: CGRect(x: 5, y: rect.size.height * 0.1, width: rect.size.height * 0.8, height: rect.size.height * 0.8)).cgPath
        
        buttonView = UIView()
        buttonView.layer.addSublayer(shapeLayer)
        buttonView.isUserInteractionEnabled = false
        
        label = UILabel(frame: CGRect(x: 5, y: rect.size.height * 0.1, width: rect.size.height * 0.8, height: rect.size.height * 0.8))
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.isUserInteractionEnabled = false
        
        mathLabel.fontSize = rect.size.height * 0.23
        mathLabel.contentInsets = UIEdgeInsetsMake(0, rect.size.height, 0, 0)
        mathLabel.sizeToFit()
        mathLabel.center.y = rect.size.height/2
        mathLabel.isUserInteractionEnabled = false
        
        titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? 0
        titleEdgeInsets = UIEdgeInsets(top: (rect.size.height) * 0.3, left: (rect.size.height) * 0.95, bottom:(rect.size.height) * 0.3, right:10)
        titleLabel?.font = titleLabel?.font.withSize(rect.size.height * 0.2)
        
        setTitleColor(UIColor.gray, for: .disabled)
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
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

class SegmentedControl : UISegmentedControl {
    
    @IBInspectable
    var segmentPadding: CGSize = CGSize.zero
    
    @IBInspectable
    var titleFontName: String?
    
    @IBInspectable
    var titleFontSize: CGFloat = UIFont.systemFontSize
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    #if TARGET_INTERFACE_BUILDER
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    #endif
    
    func setup() {
        var attributes: [NSObject : AnyObject]?
        
        if let fontName = titleFontName, let font = UIFont(name: fontName, size: titleFontSize) {
            attributes = [NSAttributedStringKey.font: font] as [NSObject : AnyObject]
        }
        
        setTitleTextAttributes(attributes, for: .normal)
    }
    
    override open var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        
        if let fontName = titleFontName, let font = UIFont(name: fontName, size: titleFontSize) {
            size.height = floor(font.lineHeight + 2 * segmentPadding.height)
        }
        else {
            size.height += segmentPadding.height * 2
        }
        
        size.width  += segmentPadding.width * CGFloat(numberOfSegments + 1)
        
        return size
    }
    
}



