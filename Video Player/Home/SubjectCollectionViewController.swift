//
//  SubjectCollectionViewController.swift
//  Video Player
//
//  Created by Lisa Wang on 6/2/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

class SubjectCollectionViewController: SwipeCollectionViewController, UICollectionViewDelegateFlowLayout {
    @IBOutlet private var subjectCollectionView: UICollectionView!
    var inset = CGFloat(20.0)
    var homeVC: HomeController?
    
    var laidOut = false
    var cellHeight = CGFloat(0.0)
    var model: Model?
    var badges = [[Badge]]() {
        didSet {
            collectionView.reloadData()
        }
    }
    var colors = [UIColor(red:0.73, green:0.93, blue:0.79, alpha:1.0), UIColor(red:0.99, green:0.81, blue:0.62, alpha:1.0), UIColor(red:0.75, green:0.87, blue:0.94, alpha:1.0)]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        model = Model()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureCollectionViewLayoutItemSize()
        //view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureCollectionViewLayoutItemSize() {
        if collectionViewFlowLayout.itemSize.width != collectionViewLayout.collectionView!.frame.size.width - inset * 2 {
            collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            collectionViewFlowLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.size.width - inset * 2, height: collectionViewLayout.collectionView!.frame.size.height)
            laidOut = true
            collectionView.reloadData()
        }
    }

    func updateHeight(height: CGFloat) {
        if height > cellHeight {
            collectionViewFlowLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.size.width - inset * 2, height: height + 40)
            self.view.layoutIfNeeded()
            homeVC!.tagContainerHeight.constant = height + 40
            homeVC!.view.layoutIfNeeded()
            cellHeight = height
            collectionView.frame = CGRect(x:0.0, y:0.0, width: collectionView.frame.size.width, height: height + 40)
            //collectionView.layoutIfNeeded()
            //collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "subjectcell", for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if laidOut && badges.count > 0 {
            
            guard let collectionViewCell = cell as? SubjectCollectionViewCell else { return }
            collectionViewCell.width = collectionViewFlowLayout.itemSize.width - inset * 2
            collectionViewCell.height = collectionViewFlowLayout.itemSize.height
            collectionViewCell.parentCollection = self
            collectionViewCell.layer.shouldRasterize = true
            collectionViewCell.layer.rasterizationScale = UIScreen.main.scale
            
            let dataProvider = TagCollectionDataSource()
            dataProvider.data = badges[(indexPath as IndexPath).item]
            dataProvider.color = colors[(indexPath as IndexPath).item]
            
            let delegate = TagCollectionDelegate()
            delegate.badges = badges[(indexPath as IndexPath).item]
            delegate.homeController = homeVC
            DispatchQueue.global(qos: .background).async {
                collectionViewCell.initializeCollectionViewWithDataSource(dataProvider, delegate: delegate, forRow: indexPath.row)
            }
            
        }
    }
}

extension UICollectionViewFlowLayout {
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

