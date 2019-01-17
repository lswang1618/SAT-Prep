//
//  AuthChoiceController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 7/18/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import Foundation
import FirebaseUI
import Lottie

class AuthChoiceController: FUIAuthPickerViewController {
    
    var imageView = LOTAnimatedControl()
    var stackView = UIStackView()
    
    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let signInLabel = UILabel()
        signInLabel.translatesAutoresizingMaskIntoConstraints = false
        signInLabel.numberOfLines = 0
        
        let attributedString = NSMutableAttributedString()
        let mainAttrs = [NSAttributedStringKey.foregroundColor: UIColor.darkGray, NSAttributedStringKey.font: UIFont(name: "Georgia", size: 24)] as [NSAttributedStringKey : Any]
        //        let secondaryAttrs = [NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.font: UIFont(name: "Georgia", size: 18)] as [NSAttributedStringKey : Any]
        
        attributedString.append(NSMutableAttributedString(string: "sign in or sign up\n", attributes: mainAttrs))
        //        attributedString.append(NSMutableAttributedString(string: "to set up practice notifications", attributes: secondaryAttrs))
        
        signInLabel.attributedText = attributedString
        signInLabel.textAlignment = .center
        
        let labelConstraint = NSLayoutConstraint(item: signInLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: view.frame.size.height*0.1)
        
        signInLabel.addConstraint(labelConstraint)
        
        imageView.animationView.setAnimation(named: "cloud")
        imageView.animationView.contentMode = .scaleAspectFill
        imageView.animationView.loopAnimation = true
        imageView.animationView.play()
        
        let imageConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: view.frame.size.height*0.3)
        
        imageView.addConstraint(imageConstraint)
        
        stackView = UIStackView(arrangedSubviews: [imageView, signInLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = -view.frame.size.height*0.2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        let viewsDictionary = ["stackView": stackView]
        let stackView_H = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[stackView]-10-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        view.addConstraints(stackView_H)
        
        let stackConstraint = NSLayoutConstraint(item: stackView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: view.frame.size.height*0.5)
        
        view.addConstraint(stackConstraint)
        
        for subview in view.subviews
        {
            for nestedView in subview.subviews {
                if nestedView is UIButton
                {
                    let factor = 2*view.frame.size.height / (5*subview.frame.size.height)
                    subview.transform = CGAffineTransform(scaleX: factor, y: factor)
                    
                    let stackview_V = NSLayoutConstraint(item: stackView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: subview, attribute: NSLayoutAttribute.top, multiplier: 1, constant: -view.frame.size.height*0.03)
                    
                    view.addConstraint(stackview_V)
                    
                    break;
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UILabel()
    }
}

