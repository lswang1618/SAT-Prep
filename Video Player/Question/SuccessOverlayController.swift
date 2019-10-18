//
//  SuccessOverlayController.swift
//  Video Player
//
//  Created by Lisa Wang on 6/19/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import Lottie

class SuccessOverlayController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var backingImageView: UIImageView!
    @IBOutlet weak var dimmerLayer: UIView!
    @IBOutlet weak var successContainer: UIView!
    
    @IBOutlet weak var backingImageTrailingInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageTopInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageLeadingInset: NSLayoutConstraint!
    @IBOutlet weak var backingImageBottomInset: NSLayoutConstraint!
    @IBOutlet weak var successContainerTopInset: NSLayoutConstraint!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var badgeTable: UITableView!
    @IBOutlet weak var cheerStackView: UIStackView!
    @IBOutlet weak var trophyView: UIView!
    @IBOutlet weak var niceWorkLabel: UILabel!
    
    let backingImageEdgeInset: CGFloat = 15.0
    let cardCornerRadius: CGFloat = 10
    var answered = false
    var answeredCorrect = false
    var primaryDuration = 0.5
    var backingImage: UIImage?
    var questions = Array<Question>()
    var name: String?
    var vc: AVPlayerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backingImageView.image = backingImage
        successContainer.layer.cornerRadius = cardCornerRadius
        successContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        badgeTable.translatesAutoresizingMaskIntoConstraints = false
        badgeTable.dataSource = self
        
        let screenHeight = UIScreen.main.bounds.height
        infoLabel.font = infoLabel.font.withSize(screenHeight * 0.019)
        niceWorkLabel.font = niceWorkLabel.font.withSize(screenHeight * 0.024)
        
        infoLabel.text = name! + " thanks you for helping with those questions! Check out the skills you built:"
        
        animationSetUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        animateBackingImageIn()
        animateImageLayerIn()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureImageLayerInStartPosition()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableRow")!

        let iconBackground = cell.viewWithTag(1)
        let icon = cell.viewWithTag(2) as! UIImageView
        let tagLabel = cell.viewWithTag(3) as! UILabel
        let subjectLabel = cell.viewWithTag(4) as! UILabel

        let question = questions[indexPath.item]
        
        let screenHeight = UIScreen.main.bounds.height
        tagLabel.font = tagLabel.font.withSize(screenHeight * 0.02)
        subjectLabel.font = subjectLabel.font.withSize(screenHeight * 0.017)
        
        iconBackground!.backgroundColor = getColorForTag(tag: question.tag)
        icon.image = UIImage(named: question.tag)
        tagLabel.text = question.tag
        subjectLabel.text = question.content.title
        
        cell.layoutSubviews()

        return cell
    }
    
    func animationSetUp() {
        let animationView = AnimationView(name: "trophy")
        animationView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.3)
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        trophyView.translatesAutoresizingMaskIntoConstraints = false
        trophyView.addSubview(animationView)
        animationView.topAnchor.constraint(equalTo: trophyView.topAnchor).isActive = true
        animationView.bottomAnchor.constraint(equalTo: trophyView.bottomAnchor).isActive = true
        animationView.centerXAnchor.constraint(equalTo: trophyView.centerXAnchor).isActive = true
        animationView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        
        animationView.play()
    }
    
    func getColorForTag(tag: String) -> UIColor {
        let model = Model()
        let tags = model.readTags()
        let colors = [UIColor(red:0.73, green:0.93, blue:0.79, alpha:1.0), UIColor(red:0.99, green:0.81, blue:0.62, alpha:1.0), UIColor(red:0.75, green:0.87, blue:0.94, alpha:1.0)]
        for (index, list) in tags.enumerated() {
            if list.contains(tag) {
                return(colors[index])
            }
        }
        return colors[0]
    }
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        vc!.dismiss(animated: false, completion: nil)
    }
}

//background image animation
extension SuccessOverlayController {
    
    //1.
    private func configureBackingImageInPosition(presenting: Bool) {
        let edgeInset: CGFloat = presenting ? backingImageEdgeInset : 0
        let dimmerAlpha: CGFloat = presenting ? 0.3 : 0
        let cornerRadius: CGFloat = presenting ? cardCornerRadius : 0
        
        backingImageLeadingInset.constant = edgeInset
        backingImageTrailingInset.constant = edgeInset
        let aspectRatio = backingImageView.frame.height / backingImageView.frame.width
        backingImageTopInset.constant = edgeInset * aspectRatio
        backingImageBottomInset.constant = edgeInset * aspectRatio
        //2.
        dimmerLayer.alpha = dimmerAlpha
        //3.
        backingImageView.layer.cornerRadius = cornerRadius
    }
    
    //4.
    private func animateBackingImage(presenting: Bool) {
        UIView.animate(withDuration: primaryDuration) {
            self.configureBackingImageInPosition(presenting: presenting)
            self.view.layoutIfNeeded() //IMPORTANT!
        }
    }
    
    //5.
    func animateBackingImageIn() {
        animateBackingImage(presenting: true)
    }
    
    func animateBackingImageOut() {
        animateBackingImage(presenting: false)
    }
}

extension SuccessOverlayController {
    
    //1.
    private var imageLayerInsetForOutPosition: CGFloat {
        let inset = UIScreen.main.bounds.height - backingImageEdgeInset
        return inset
    }
    
    //2.
    func configureImageLayerInStartPosition() {
        let startInset = imageLayerInsetForOutPosition
        successContainer.layer.cornerRadius = 0
        successContainerTopInset.constant = startInset
        view.layoutIfNeeded()
    }
    
    //3.
    func animateImageLayerIn() {
        //4.
        UIView.animate(withDuration: primaryDuration / 4.0) {
            
        }
        
        //5.
        UIView.animate(withDuration: primaryDuration, delay: 0, options: [.curveEaseIn], animations: {
            self.successContainerTopInset.constant = 0
            self.successContainer.layer.cornerRadius = self.cardCornerRadius
            self.view.layoutIfNeeded()
        })
    }
    
    func animateImageLayerOut(completion: @escaping ((Bool) -> Void)) {
        let endInset = imageLayerInsetForOutPosition
        
        UIView.animate(withDuration: primaryDuration / 4.0,
                       delay: primaryDuration,
                       options: [.curveEaseOut], animations: {
                        
        }, completion: { finished in
            completion(finished) //fire complete here , because this is the end of the animation
        })
        
        UIView.animate(withDuration: primaryDuration, delay: 0, options: [.curveEaseOut], animations: {
            self.successContainerTopInset.constant = endInset
            self.successContainer.layer.cornerRadius = 0
            self.view.layoutIfNeeded()
        })
    }
}

