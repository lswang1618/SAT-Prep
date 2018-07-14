//
//  BadgeDetailViewController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 6/11/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

class BadgeDetailViewController: UIViewController {
    
    @IBOutlet weak var badgeNameLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var bronzeBadge: UIImageView!
    @IBOutlet weak var silverBadge: UIImageView!
    @IBOutlet weak var goldBadge: UIImageView!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var finishedCount: UILabel!
    @IBOutlet weak var progressView: RoundedCornerView!
    
    @IBAction func handleGoldTap(recognizer: UITapGestureRecognizer) {
        if selected != 2 {
            selected = 2
            configureColor(imageView: mainImage, vIndex: selected!, grad: gradient, gradView: progressView)
            configureCount(vIndex: selected!)
        }
    }
    
    @IBAction func handleSilverTap(recognizer: UITapGestureRecognizer) {
        if selected != 1 {
            selected = 1
            configureColor(imageView: mainImage, vIndex: selected!, grad: gradient, gradView: progressView)
            configureCount(vIndex: selected!)
        }
    }
    
    @IBAction func handleBronzeTap(recognizer: UITapGestureRecognizer) {
        if selected != 0 {
            selected = 0
            configureColor(imageView: mainImage, vIndex: selected!, grad: gradient, gradView: progressView)
            configureCount(vIndex: selected!)
        }
    }
    
    var badge: Badge?
    var color: UIColor?
    var image: UIImage?
    var selected: Int?
    var level: Int?
    var strokeStart: CGFloat = 0.0
    let circleShape = CAShapeLayer()
    let progressColor = UIColor(red:0.11, green:1.00, blue:0.73, alpha:1.0)
    let gradient = CAGradientLayer()
    
    override func viewWillAppear(_ animated: Bool) {
        badgeNameLabel.text = badge?.tag
        finishedCount.isHidden = true
        count.isHidden = true
        
        if badge!.progress < 10 {
            level = 0
            selected = 0
        } else if badge!.progress < 25 {
            level = 1
            selected = 1
        } else if badge!.progress < 50 {
            level = 2
            selected = 2
        }else {
            level = 3
            selected = 2
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        configureBadgeImage(imageView: mainImage)
        configureColor(imageView: mainImage, vIndex: selected!, grad: gradient, gradView: progressView)
        configureCount(vIndex: selected!)
        
        let gBronze = CAGradientLayer()
        configureBadgeImage(imageView: bronzeBadge)
        configureColor(imageView: bronzeBadge, vIndex: 0, grad: gBronze, gradView: bronzeBadge)
        
        let gSilver = CAGradientLayer()
        configureBadgeImage(imageView: silverBadge)
        configureColor(imageView: silverBadge, vIndex: 1, grad: gSilver, gradView: silverBadge)
        
        let gGold = CAGradientLayer()
        configureBadgeImage(imageView: goldBadge)
        configureColor(imageView: goldBadge, vIndex: 2, grad: gGold, gradView: goldBadge)
    }
    
    func configureBadgeImage(imageView: UIImageView) {
        image = UIImage(named:badge!.tag)?.imageWithInsets(insets: UIEdgeInsetsMake(20, 20, 20, 20))
        imageView.image = image!.withRenderingMode(.alwaysTemplate)
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.layer.borderWidth = 3
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
    }
    
    func configureColor(imageView: UIImageView, vIndex: Int, grad: CAGradientLayer, gradView: UIView) {
        if level! > vIndex {
            imageView.tintColor = color
            
            grad.frame =  CGRect(x: progressView.frame.origin.x, y: progressView.frame.origin.y, width: progressView.frame.size.width, height: progressView.frame.size.height)
            
            switch vIndex {
            case 0:
                imageView.layer.borderColor = UIColor(red:0.80, green:0.50, blue:0.20, alpha:1.0).cgColor
                
                grad.colors = [UIColor(red:0.64, green:0.40, blue:0.16, alpha:1.0).cgColor, UIColor(red:0.86, green:0.65, blue:0.44, alpha:1.0).cgColor]
            case 1:
                imageView.layer.borderColor = UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.0).cgColor
                
                grad.colors = [UIColor(red:0.86, green:0.86, blue:0.86, alpha:1.0).cgColor, UIColor(red:0.41, green:0.41, blue:0.41, alpha:1.0).cgColor]
            case 2:
                imageView.layer.borderColor = UIColor(red:0.98, green:0.75, blue:0.23, alpha:1.0).cgColor
                
                grad.colors = [UIColor(red:1.00, green:0.99, blue:0.75, alpha:1.0).cgColor, UIColor(red:0.98, green:0.75, blue:0.23, alpha:1.0).cgColor]
            default:
                imageView.layer.borderColor = UIColor.white.cgColor
            }
            
            let shape = CAShapeLayer()
            shape.lineWidth = imageView.frame.size.width*0.15
            shape.path = UIBezierPath(arcCenter: CGPoint (x: imageView.frame.size.width / 2, y: imageView.frame.size.height / 2),
                                      radius: imageView.frame.width / 2,
                                      startAngle: CGFloat(-0.5 * .pi),
                                      endAngle: CGFloat(1.5 * .pi),
                                      clockwise: true).cgPath
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor
            grad.mask = shape
            
            imageView.layer.addSublayer(grad)
        } else {
            imageView.tintColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
            imageView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func configureCount(vIndex: Int) {
        let progress = String(format:"%i", (badge?.progress)!)
        
        if (badge?.progress)! > 49 && vIndex == 2{
            count.isHidden = true
            finishedCount.text = progress
            finishedCount.isHidden = false
            
        } else {
            finishedCount.isHidden = true
            let attributedString = NSMutableAttributedString()
            let attrs = [NSAttributedStringKey.foregroundColor : progressColor]
            let attrs2 = [NSAttributedStringKey.foregroundColor : UIColor.black]
            attributedString.append(NSMutableAttributedString(string: progress, attributes:attrs))
            if level! <= vIndex {
                gradient.removeFromSuperlayer()
                
                switch vIndex {
                case 0:
                    attributedString.append(NSMutableAttributedString(string: "\n/10", attributes:attrs2))
                    drawProgress(percent: CGFloat(badge!.progress)/CGFloat(10.0))
                case 1:
                    attributedString.append(NSMutableAttributedString(string: "\n/25", attributes:attrs2))
                    drawProgress(percent: CGFloat(badge!.progress)/CGFloat(25.0))
                case 2:
                    attributedString.append(NSMutableAttributedString(string: "\n/50", attributes:attrs2))
                    drawProgress(percent: CGFloat(badge!.progress)/CGFloat(50.0))
                default:
                    count.isHidden = true
                }
                count.attributedText = attributedString
                count.isHidden = false
                
            } else {
                count.isHidden = true
                progressView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                strokeStart = 0.0
            }
        }
    }
    
    
    func drawProgress(percent: CGFloat) {
        // bezier path
        var circlePath = UIBezierPath()
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.0)
        if strokeStart < percent {
            circlePath = UIBezierPath(arcCenter: CGPoint (x: progressView.frame.size.width / 2, y: progressView.frame.size.height / 2),
                                      radius: mainImage.frame.size.width / 2,
                                      startAngle: CGFloat(-0.5 * .pi),
                                      endAngle: CGFloat(1.5 * .pi),
                                      clockwise: true)
            // circle shape
            circleShape.path = circlePath.cgPath
            circleShape.fillColor = UIColor.clear.cgColor
            circleShape.strokeColor = progressColor.cgColor
            circleShape.lineWidth = 8
            circleShape.strokeEnd = 0.0
            
            // add sublayer
            progressView.layer.addSublayer(circleShape)
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            
            // Set the animation duration appropriately
            animation.duration = 1.0
            
            // Animate from 0 (no circle) to 1 (full circle)
            animation.fromValue = strokeStart
            animation.toValue = percent
            
            // Do a linear animation (i.e. the speed of the animation stays the same)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            
            // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
            // right value when the animation ends.
            circleShape.strokeEnd = percent
            strokeStart = percent
            
            // Do the actual animation
            circleShape.add(animation, forKey: "animateCircle")
            
        } else {
            circleShape.removeAllAnimations()
            circleShape.strokeEnd = percent
            strokeStart = percent
        }
        CATransaction.commit()
    }
}
