//
//  SubjectCollectionViewCell.swift
//  Video Player
//
//  Created by Lisa Wang on 6/2/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import UIKit

protocol CollectionViewSelectedProtocol {
    func collectionViewSelected(_ collectionViewItem : Int)
}

class SubjectCollectionViewCell: UICollectionViewCell {
    var collectionViewDataSource : UICollectionViewDataSource!
    var collectionViewDelegate : UICollectionViewDelegate!
    var collectionView : UICollectionView!
    var delegate : CollectionViewSelectedProtocol!
    var parentCollection : SubjectCollectionViewController?
    
    var width = CGFloat(0.0)
    var height = CGFloat(0.0)
    
    @IBOutlet weak var cellView: UIView!
    
    func initializeCollectionViewWithDataSource<D: UICollectionViewDataSource,E: UICollectionViewDelegate>(_ dataSource: D, delegate :E, forRow row: Int) {
        
        self.collectionViewDataSource = dataSource
        
        self.collectionViewDelegate = delegate
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        DispatchQueue.main.async {
            let collectionView = UICollectionView(frame: CGRect(x: 0.0, y: 0.0, width: self.width, height: self.height), collectionViewLayout: flowLayout)
            
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "embedCell")
            collectionView.backgroundColor = UIColor.clear
            collectionView.dataSource = self.collectionViewDataSource
            collectionView.delegate = self.collectionViewDelegate
            collectionView.tag = row
            self.cellView.addSubview(collectionView)
            self.collectionView = collectionView
            collectionView.layoutIfNeeded()
            collectionView.frame = CGRect(x:0.0, y:0.0, width: self.width, height: collectionView.contentSize.height)
            //collectionView.layoutIfNeeded()
            self.parentCollection?.updateHeight(height: collectionView.contentSize.height)
        }
    }
    
    override func prepareForReuse() {
        collectionView.removeFromSuperview()
    }
}
