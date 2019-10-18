//
//  TagCellView.swift
//  Video Player
//
//  Created by Lisa Wang on 6/17/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import UIKit

class TagCellView: UIView {
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tagNameLabel: UILabel!
    @IBOutlet weak var tagProgressLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
