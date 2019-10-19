//
//  BadgeCellCollectionViewCell.swift
//  SAT Prep
//
//  Created by Lisa Wang on 6/10/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import UIKit

class BadgeCellCollectionViewCell: UICollectionViewCell {
    var label : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
        
        addSubview(label)
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsDictionary = ["label": label]
        let label_H = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-5-[label]-5-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        let label_B = NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
        
        let imageDictionary = ["imageView": imageView]
        let imageView_H = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-5-[imageView]-5-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: imageDictionary)
        let imageView_T = NSLayoutConstraint.init(item: imageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
        
        addConstraints(imageView_H)
        addConstraints(label_H)
        addConstraints([imageView_T, label_B])

        
    }
}
