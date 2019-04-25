//
//  UIView+Snapshot.swift
//  Video Player
//
//  Created by Lisa Wang on 4/25/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import UIKit

extension UIView  {
    func makeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
