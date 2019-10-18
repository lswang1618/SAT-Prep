//
//  Extensions.swift
//  Video Player
//
//  Created by Lisa Wang on 6/10/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
//
//let imageCache = NSCache<UIImage, String>()
//
//extension UIImageView {
//    func loadImageUsingCacheWithURLString(urlString: String) {
//        
//        //check cache for image first
//        if let cachedImage = imageCache.objectForKey(urlString) as? UIImage {
//            self.image = cachedImage
//            return
//        }
//        
//        let url = NSURL(string: urlString)
//        URLSession.shared.dataTaskWithURL(url! as URL, completionHandler: { (data, response, error) in
//            if error != nil {
//                print(error)
//                return
//            }
//            if let downloadedImage = UIImage(data: data!) {
//                imageCache.setObject(downloadedImage, forKey: urlString)
//            }
//            
//            self.image = downloadedImage
//        }).resume()
//        
//    }
//}
