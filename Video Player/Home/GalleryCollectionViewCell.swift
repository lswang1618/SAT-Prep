//
//  GalleryCollectionViewCell.swift
//  Video Player
//
//  Created by Lisa Wang on 6/9/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var tagLabel: EdgeInsetLabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconBackgroundView?.layer.cornerRadius = (self.frame.size.height - 50)/2.0/3.0
    }
    
    override func prepareForReuse() {
        tagLabel.isHidden = false
    }
}
