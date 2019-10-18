//
//  TagCollectionDataSource.swift
//  Video Player
//
//  Created by Lisa Wang on 6/3/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import UIKit

class TagCollectionDataSource : NSObject, UICollectionViewDataSource {
    
    var data = [Badge]()
    var color = UIColor.white
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "embedCell", for: indexPath)
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                cell.layer.cornerRadius = 5
                let cellView =  Bundle.main.loadNibNamed("TagCellView", owner: self, options: nil)?.first as! TagCellView
                cell.backgroundColor = UIColor.white
                cellView.frame = cell.bounds
                cellView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                cellView.iconBackgroundView.layer.cornerRadius = (cell.frame.size.height - 10)*0.4/2.0
                cellView.iconBackgroundView.backgroundColor = self.color
                let badge = self.data[(indexPath as IndexPath).item]
                let progress = CGFloat(badge.lastIndex)/5.0

                cellView.tagNameLabel.text = badge.tag
                
                cellView.iconImageView.image = UIImage(named: badge.tag)
                cellView.tagProgressLabel.text = String(Int(progress * 100)) + "% Done"

                let screenHeight = UIScreen.main.bounds.height
                cellView.tagNameLabel.font = cellView.tagNameLabel.font.withSize(screenHeight * 0.018)
                cellView.tagProgressLabel.font = cellView.tagProgressLabel.font.withSize(screenHeight * 0.018)

                var color = UIColor.white
                var bgColor = UIColor.white
                if badge.subject == "Math" {
                    color = UIColor(red:0.98, green:0.48, blue:0.07, alpha:1.0)
                    bgColor = UIColor(red:0.99, green:0.81, blue:0.62, alpha:1.0)
                } else if badge.subject == "Reading" {
                    color = UIColor(red:0.18, green:0.75, blue:0.44, alpha:1.0)
                    bgColor = UIColor(red:0.73, green:0.93, blue:0.79, alpha:1.0)
                } else {
                    color = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
                    bgColor = UIColor(red:0.75, green:0.87, blue:0.94, alpha:1.0)
                }

                if badge.lastIndex == 5 {
                    cellView.backgroundColor = bgColor
                }
            
                cell.addSubview(cellView)
                cell.layer.addBorder(edge: .bottom, color: color, thickness: 2.0, widthPercent: progress)
            }
        }
        return cell
    }
    
}

