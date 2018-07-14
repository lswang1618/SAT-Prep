//
//  BadgeViewController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 6/10/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

class BadgeViewController: UICollectionViewController {
    
    let model = Model()
    var allTags: [String: Array<String>] = [:]
    var tags = [String]()
    var currentIndex = 0
    var allBadges = [Badge]()
    var badges = [Badge]()
    var colors = [UIColor(red:0.33, green:0.33, blue:0.42, alpha:1.0),
                  UIColor(red:0.37, green:0.79, blue:0.00, alpha:1.0),
                  UIColor(red:0.85, green:0.44, blue:0.18, alpha:1.0),
                  UIColor(red:0.92, green:0.00, blue:0.78, alpha:1.0),
                  UIColor(red:0.48, green:0.53, blue:0.88, alpha:1.0),
                  UIColor(red:0.56, green:0.43, blue:0.80, alpha:1.0),
                  UIColor(red:0.26, green:0.73, blue:0.88, alpha:1.0),
                  UIColor(red:0.00, green:0.66, blue:0.25, alpha:1.0),
                  UIColor(red:1.00, green:0.84, blue:0.18, alpha:1.0),
                  UIColor(red:1.00, green:0.28, blue:0.33, alpha:1.0),
                  UIColor(red:0.05, green:0.40, blue:0.75, alpha:1.0),
                  UIColor(red:0.34, green:0.90, blue:0.86, alpha:1.0),
                  UIColor(red:1.00, green:0.61, blue:0.00, alpha:1.0)]
    
    //UI Constants
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 50.0, right: 20.0)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTags = model.readTags()
        let parent = self.parent as! BadgeController
        currentIndex = parent.getIndex()
        switch currentIndex {
        case 0:
            tags = allTags["reading"]!
        case 1:
            tags = allTags["writing"]!
            fetchBadges(p: parent)
        case 2:
            tags = allTags["math"]!
            fetchBadges(p: parent)
        default:
            tags = allTags["reading"]!
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.collectionView?.reloadData()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseCell",
                                                      for: indexPath) as! BadgeCellCollectionViewCell
        cell.backgroundColor = UIColor.white
        let badge = badgeForIndexPath(indexPath: indexPath)
        
        // Configure the cell label
        cell.label.text = badge.tag
        cell.label.numberOfLines = 0
        cell.label.lineBreakMode = .byWordWrapping
        cell.label.font = cell.label.font.withSize(self.view.frame.height * 0.015)
        cell.label.textColor = UIColor.gray
        
        // Get size of cell
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        // Add image to UIImageView
        let image = UIImage(named:badge.tag)?.imageWithInsets(insets: UIEdgeInsetsMake(30, 30, 30, 30))?.withRenderingMode(.alwaysTemplate)
        cell.imageView.image = image
        
        let imageViewWidthConstraint = NSLayoutConstraint(item: cell.imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: widthPerItem*0.9)
        let imageViewHeightConstraint = NSLayoutConstraint(item: cell.imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: widthPerItem*0.9)
        
        cell.imageView.addConstraints([imageViewWidthConstraint, imageViewHeightConstraint])
        
        // Round badge corners
        cell.imageView.layer.cornerRadius = widthPerItem*0.9/2
        cell.imageView.layer.borderWidth = 4
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.masksToBounds = true
        cell.imageView.contentMode = .scaleAspectFit
        
        cell.imageView.tintColor = colors[(indexPath as IndexPath).item]
        // Set badge color
        if badge.progress < 10 {
            cell.imageView.tintColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
            cell.imageView.layer.borderColor = UIColor.white.cgColor
        } else if badge.progress < 25 {
            cell.imageView.layer.borderColor = UIColor(red:0.80, green:0.50, blue:0.20, alpha:1.0).cgColor
        } else if badge.progress < 50 {
            cell.imageView.layer.borderColor = UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.0).cgColor
        } else {
            cell.imageView.layer.borderColor = UIColor(red:0.98, green:0.75, blue:0.23, alpha:1.0).cgColor
        }
        
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? UICollectionViewCell,
            let indexPath = self.collectionView?.indexPath(for: cell) {
            
            let vc = segue.destination as! BadgeDetailViewController
            vc.badge = badges[indexPath.item]
            vc.color = colors[indexPath.item]
        }
    }
    
    func fetchBadges(p: BadgeController) {
        if allBadges.count == 0 {
            allBadges = p.getBadges()
        }
        for badge in allBadges {
            if tags.contains(badge.tag) {
                self.badges.append(badge)
            }
        }
        collectionView?.reloadData()
    }
    
    func badgeForIndexPath(indexPath: IndexPath) -> Badge {
        if badges.count > 0 {
            return badges[(indexPath as IndexPath).item]
        } else {
            return Badge()!
        }
    }
}

extension BadgeViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension UIImage {
    func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}

