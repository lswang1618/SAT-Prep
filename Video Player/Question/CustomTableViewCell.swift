//
//  CustomTableViewCell.swift
//  Video Player
//
//  Created by Lisa Wang on 7/9/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var iconBackground: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconBackground?.layer.cornerRadius = (self.frame.size.width) * 0.2 / 2.0
    }
}
