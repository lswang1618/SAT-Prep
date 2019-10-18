//
//  TagCollectionDelegate.swift
//  Video Player
//
//  Created by Lisa Wang on 6/3/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

class TagCollectionDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var badges = [Badge]()
    var homeController: HomeController?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let badge = badges[(indexPath as IndexPath).item]
        let model = Model()
        model.getTagQuestion(index: badge.lastIndex, tag: badge.tag, subject: badge.subject) { result in
            if result != nil {
                weak var questionOverlay = self.homeController?.storyboard?.instantiateViewController(withIdentifier: "QuestionOverlayViewController") as? QuestionOverlayViewController
                
                questionOverlay!.backingImage = self.homeController?.view.makeSnapshot()
                questionOverlay!.question = result
                
                if badge.subject == "Math" {
                    questionOverlay!.endColor = UIColor(red:0.98, green:0.48, blue:0.07, alpha:1.0)
                    questionOverlay!.startColor = UIColor(red:0.98, green:0.48, blue:0.07, alpha:0.3)
                    questionOverlay!.view.backgroundColor = UIColor(red:0.98, green:0.48, blue:0.07, alpha:1.0)
                } else if badge.subject == "Writing" {
                    questionOverlay!.endColor = UIColor(red:0.00, green:0.73, blue:1.00, alpha:1.0)

                    questionOverlay!.startColor = UIColor(red:0.00, green:0.73, blue:1.00, alpha:0.3)

                    questionOverlay!.view.backgroundColor = UIColor(red:0.00, green:0.73, blue:1.00, alpha:1.0)

                } else if badge.subject == "Reading" {
                    questionOverlay!.endColor = UIColor(red:0.18, green:0.75, blue:0.44, alpha:1.0)
                    questionOverlay!.startColor = UIColor(red:0.18, green:0.75, blue:0.44, alpha:0.3)
                    questionOverlay!.view.backgroundColor = UIColor(red:0.18, green:0.75, blue:0.44, alpha:1.0)
                }
                questionOverlay?.modalPresentationStyle = .fullScreen
                self.homeController?.present(questionOverlay!, animated: true)
                questionOverlay!.dimmerLayer.isHidden = true
                questionOverlay!.backingImageView.isHidden = true
                questionOverlay!.animateImageLayerIn()
                questionOverlay!.scrollViewHeight.constant = min(questionOverlay!.stackView.frame.size.height + 30, UIScreen.main.bounds.height*0.7)
                questionOverlay!.view.layoutSubviews()
                questionOverlay!.animateOverlay = false
                questionOverlay!.isNormalQ = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let rowWidth = collectionViewLayout.collectionView!.frame.size.width
        let cellWidth = (rowWidth - 20)/2
        
        if cellWidth > 0 {
            return CGSize(width: cellWidth, height: cellWidth / 1.6)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(10.0)
    }
}
