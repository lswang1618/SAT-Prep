//
//  FlowLayout.swift
//  Video Player
//
//  Created by Lisa Wang on 6/4/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation

class FlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
