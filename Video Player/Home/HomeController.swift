//
//  HomeController.swift
//  Video Player
//
//  Created by Lisa Wang on 6/2/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SJFluidSegmentedControl
import Lottie

class HomeController: UIViewController {
    @IBOutlet weak var galleryControl: UIPageControl!
    var galleryController: GalleryController?
    var tagController: SubjectCollectionViewController?
    var user: User?
    var badgeDict = [[Badge]]()
    var model: Model?
    var name: String?
    var email: String?
    var targetSubject: String?
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var tagContainer: UIView!
    @IBOutlet weak var tagContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var subjectSelector: SJFluidSegmentedControl!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if it's a segue going to TableViewController and it has
        // the identifier we set in the storyboard, then this is the
        // tableViewController we want to get
        if segue.identifier == "gallerysegue" {
            let vc = segue.destination as? GalleryController
            vc?.homeController = self
            self.galleryController = vc
        }
        if segue.identifier == "tagsegue" {
            let vc = segue.destination as? SubjectCollectionViewController
            self.tagController = vc
            vc?.homeVC = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryController?.pageControl = galleryControl
        tagController?.segmentedControl = subjectSelector
        subjectSelector.delegate = self
        subjectSelector.isHidden = true
        subjectSelector.layer.cornerRadius = subjectSelector.frame.size.height * 0.6
        
        for view in subjectSelector.subviews {
            for subview in view.subviews {
                if let label = subview as? UILabel {
                    label.font = label.font.withSize(UIScreen.main.bounds.height * 0.02)
                }
            }
        }
        
        model = Model()
        if name != nil {
            model!.createNewAnonUser(name: name!, email: email!, targetSubject: targetSubject!) { result in
                self.user = result
                self.setUpForUser()
            }
        }
        else if user == nil {
            model!.getUser() { result in
                self.user = result
                self.setUpForUser()
            }
        } else {
            setUpForUser()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        let screenHeight = UIScreen.main.bounds.height
//        appNameLabel.font = appNameLabel.font.withSize(screenHeight * 0.023)
        //animationSetUp()
    }
    
    func animationSetUp() {
        let animationView = AnimationView(name: "blue_stars")
        animationView.frame = CGRect(x:0, y:loadingView.frame.size.height / 1.5, width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.height * 0.3)
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(animationView)
        animationView.topAnchor.constraint(equalTo: loadingView.topAnchor).isActive = true
        animationView.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor).isActive = true
        animationView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        animationView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        
        animationView.play()
    }
    
    func setUpForUser() {
        // get videos in order
        model?.getVideos(startIndex: user!.videoIndex) { [unowned self] results in
            
            if results != nil {
                self.galleryController!.dataSource = results!
                
                self.galleryController!.pageControl?.numberOfPages = self.galleryController!.dataSource.count
                self.galleryController?.videoProgress = self.user!.videoProgress
            }
        }
        // get badge progress
        model?.getBadges(userID: user!.uid) { badges in
            var resultBadges = badges
            self.badgeDict = [[Badge]]()
            self.badgeDict.append(Array(resultBadges.prefix(14)))
            resultBadges = Array(resultBadges.dropFirst(14))
            self.badgeDict.insert(Array(resultBadges.prefix(13)), at: 0)
            resultBadges = Array(resultBadges.dropFirst(13))
            self.badgeDict.append(resultBadges)
            self.tagController!.badges = self.badgeDict
            self.subjectSelector.isHidden = false
            var answeredToday = false
            if self.user!.lastAnswered as? Int != 0 {
                let lastDate = self.user!.lastAnswered as AnyObject
                let date = lastDate.dateValue()
                let calendar = Calendar.current
                
                if calendar.isDateInToday(date) {
                    answeredToday = true
                }
            }
            
            if self.user!.tagsCompleted < 42 && !answeredToday{
                self.getQOfTheDay()
            } else {
                self.galleryController?.questionOfTheDay = nil
            }
        }
    }
    
    func getQOfTheDay() {
        var subject = user?.targetSubject
        var tag = ""
        var lastIndex = 0
        switch subject {
        case "Math":
            let badge = badgeDict[1][0]
            tag = badge.tag
            lastIndex = badge.lastIndex
        case "Reading":
            let badge = badgeDict[0][0]
            tag = badge.tag
            lastIndex = badge.lastIndex
        case "Writing":
            let badge = badgeDict[2][0]
            tag = badge.tag
            lastIndex = badge.lastIndex
        default:
            let badge = badgeDict[2][0]
            tag = badge.tag
            lastIndex = badge.lastIndex
            subject = "Writing"
        }
        
        model?.getTagQuestion(index: lastIndex, tag: tag, subject: subject!) { result in
            if result != nil {
                if self.galleryController?.questionOfTheDay == nil {
                    self.galleryController!.pageControl?.numberOfPages += 1
                }
                self.galleryController?.questionOfTheDay = result
                self.galleryController?.dailyQText = self.getDailyQText()
                
            }
            else {
                self.galleryController?.questionOfTheDay = nil
            }
        }
    }
    
    func getDailyQText() -> String{
        let subjects = ["Reading", "Writing", "Math"]
        let nonTargets = subjects.filter { $0 != user!.targetSubject }
        var dict = [String: Int]()
        dict["Math"] = user!.Math
        dict["Reading"] = user!.Reading
        dict["Writing"] = user!.Writing
        
        if dict["Math"] == 0 && dict["Writing"] == 0 && dict["Reading"] == 0 {
            if subjects.contains(user!.targetSubject) {
                return "Let's start with some " + user!.targetSubject + " practice."
            } else {
                return "Let's start with some Writing practice."
            }
        } else if dict[nonTargets[0]] == dict[nonTargets[1]] && dict[nonTargets[0]]! > dict[user!.targetSubject]! {
            return "You're doing great at " + nonTargets[0] + " and " + nonTargets[1] + "! Now let's practice some " + user!.targetSubject + "."
        } else if dict[nonTargets[0]]! > dict[nonTargets[1]]! {
            return "You're breezing through " + nonTargets[0] + "! Now let's try a " + user!.targetSubject + " question."
        } else if dict[nonTargets[0]]! < dict[nonTargets[1]]!{
            return "You're acing the " + nonTargets[1] + " questions! Now let's try a " + user!.targetSubject + " question."
        } else {
            return "Let's try a " + user!.targetSubject + " question."
        }
    }
    
    func requestFeedback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let alert = UIAlertController(title: "How can we improve this app? 🤔", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = ""
            })
            
            alert.addAction(UIAlertAction(title: "Send", style: .default, handler: {[unowned self] action in
                if let feedback = alert.textFields?.first?.text {
                    self.model?.sendFeedback(feedback: feedback, userID: self.user!.uid)
                }
            }))
            
            self.present(alert, animated: true)
        }
    }
}

extension HomeController: SJFluidSegmentedControlDataSource, SJFluidSegmentedControlDelegate {
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 3
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          titleForSegmentAtIndex index: Int) -> String? {
        if index == 0 {
            return "Reading"
        } else if index == 1 {
            return "Math"
        }
        return "Writing"
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForSelectedSegmentAtIndex index: Int) -> [UIColor] {
        return [UIColor.black, UIColor.black]
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForBounce bounce: SJFluidSegmentedControlBounce) -> [UIColor] {
        return [UIColor.clear, UIColor.clear]
    }
    
    @objc func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                                didChangeFromSegmentAtIndex fromIndex: Int,
                                toSegmentAtIndex toIndex:Int) {
        let indexPath = IndexPath(row: toIndex, section: 0)
        tagController?.collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
    }
    
    
}

