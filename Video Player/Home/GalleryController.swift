//
//  GalleryController.swift
//  Video Player
//
//  Created by Lisa Wang on 6/2/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import Cache
import Imaginary

class GalleryController: SwipeCollectionViewController {
    var dataSource = Array<Video>() {
        didSet {
            collectionView?.reloadData()
        }
    }
    var questionOfTheDay: Question? {
        didSet {
            collectionView?.reloadData()
        }
    }
    var dailyQText = ""
    var videoProgress = [Int]()
    var model: Model?
    var homeController: HomeController?
    let diskConfig = DiskConfig(name: "DiskCache")
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    lazy var storage: Cache.Storage? = {
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureCollectionViewLayoutItemSize()
    }
    
    private func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = calculateSectionInset()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        collectionViewFlowLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.size.width - inset * 2, height: collectionViewLayout.collectionView!.frame.size.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if questionOfTheDay == nil {
            return dataSource.count
        } else {
            return dataSource.count + 1
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gallerycell", for: indexPath)
        let backgroundImage = cell.viewWithTag(97) as! UIImageView
        let card = cell.viewWithTag(98)
        let stackView = cell.viewWithTag(99) as! UIStackView
        let iconBackgroundView = cell.viewWithTag(100)
        let iconView = cell.viewWithTag(101) as! UIImageView
        let titleLabel = cell.viewWithTag(102) as! UILabel
        let subTitleLabel = cell.viewWithTag(103) as! UILabel
        let tagLabel = cell.viewWithTag(104) as! UILabel
        
        let index = (indexPath as IndexPath).item
        let screenHeight = UIScreen.main.bounds.height
        stackView.spacing = screenHeight * 0.03
        titleLabel.font = titleLabel.font.withSize(screenHeight * 0.0295)
        subTitleLabel.font = subTitleLabel.font.withSize(screenHeight * 0.02)
        tagLabel.font = tagLabel.font.withSize(screenHeight * 0.02)
        
//        card?.layer.masksToBounds = false
//        card?.layer.applySketchShadow(
//            color: UIColor(red:0.53, green:0.53, blue:0.53, alpha:0.5),
//            alpha: 0.5,
//            x: 5,
//            y: 10,
//            blur: 20,
//            spread: 0)

        if index == 0 && questionOfTheDay != nil {
            titleLabel.text = "Your Question of the Day"
            subTitleLabel.text = dailyQText
            tagLabel.text = questionOfTheDay?.tag
            iconView.image = UIImage(named: "QuestionIcon")
            card?.backgroundColor = UIColor(red:0.00, green:0.73, blue:1.00, alpha:1.0)
            iconBackgroundView!.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.25)
        } else {
            var videoIndex = index - 1
            
            if questionOfTheDay == nil {
                videoIndex = index
            }
            
            titleLabel.text = dataSource[videoIndex].title
            subTitleLabel.text = dataSource[videoIndex].subTitle
            //iconView.image = UIImage(named: dataSource[videoIndex].name)
            iconView.image = UIImage(named: "Play")
            card?.backgroundColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:0.5)
            iconBackgroundView!.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.0)
            
            if dataSource[videoIndex].index < videoProgress.count {
                
                if videoProgress[dataSource[videoIndex].index] > 0 {
                    tagLabel.text = String(Int(Float(videoProgress[dataSource[videoIndex].index]) / 6.0 * 100)) + "% Done"
                } else {
                    tagLabel.isHidden = true
                }
            } else {
                tagLabel.isHidden = true
            }
            
            let url = URL(string: dataSource[videoIndex].snap)
            if url != nil {
                backgroundImage.setImage(url: url!)
            }
            
        }
        return(cell)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = (indexPath as IndexPath).item
        if index == 0 && questionOfTheDay != nil{
            weak var questionOverlay = self.homeController?.storyboard?.instantiateViewController(withIdentifier: "QuestionOverlayViewController") as? QuestionOverlayViewController
            
            questionOverlay!.backingImage = self.homeController?.view.makeSnapshot()
            questionOverlay!.question = questionOfTheDay
            questionOverlay!.modalPresentationStyle = .fullScreen
            self.homeController?.present(questionOverlay!, animated: true)
            questionOverlay!.dimmerLayer.isHidden = true
            questionOverlay!.backingImageView.isHidden = true
            if questionOfTheDay!.subject == "Math" {
                questionOverlay!.endColor = UIColor(red:0.98, green:0.48, blue:0.07, alpha:1.0)
                questionOverlay!.startColor = UIColor(red:0.98, green:0.48, blue:0.07, alpha:0.3)
                questionOverlay!.view.backgroundColor = UIColor(red:0.98, green:0.48, blue:0.07, alpha:1.0)
            } else if questionOfTheDay!.subject == "Writing" {
                questionOverlay!.endColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
                questionOverlay!.startColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:0.3)
                questionOverlay!.view.backgroundColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
            } else if questionOfTheDay!.subject == "Reading" {
                questionOverlay!.endColor = UIColor(red:0.18, green:0.75, blue:0.44, alpha:1.0)
                questionOverlay!.startColor = UIColor(red:0.18, green:0.75, blue:0.44, alpha:0.3)
                questionOverlay!.view.backgroundColor = UIColor(red:0.18, green:0.75, blue:0.44, alpha:1.0)
            }
            questionOverlay!.animateImageLayerIn()
            questionOverlay!.scrollViewHeight.constant = min(questionOverlay!.stackView.frame.size.height + 30, UIScreen.main.bounds.height*0.7)
            questionOverlay!.view.layoutSubviews()
            questionOverlay!.animateOverlay = false
            questionOverlay!.isDailyQ = true
        } else {
//            let vc = VideoController()
//            self.present(vc, animated: true)
            var videoIndex = index
            if questionOfTheDay != nil {
                videoIndex = index - 1
            }
            let video = dataSource[videoIndex]
            
            if video.index < videoProgress.count && videoProgress[video.index] < 6 && videoProgress[video.index] > 0{
                self.initializeVideo(video: video, startTime: video.boundaries[videoProgress[video.index]-1].0)
            } else {
                if video.index >= videoProgress.count {
                    let oldVideoProgress = videoProgress
                    videoProgress = [Int](repeating: 0, count: video.index + 1)
                    
                    for (i, v) in oldVideoProgress.enumerated() {
                        videoProgress[i] = v
                    }
                }
                
                self.initializeVideo(video: video, startTime: 0)
            }
        }
    }
    
    func initializeVideo(video: Video, startTime: Int) {
        let url = URL(string: video.url)!
        let vc = AVPlayerViewController()
        if #available(iOS 13.0, *) {
            let entry = try? storage!.entry(forKey: url.absoluteString)
            let playerItem: CachingPlayerItem
            
            if entry != nil {
                
                playerItem = CachingPlayerItem(data: entry!.object, mimeType: "video/mp4", fileExtension: "mp4")
            } else {
                
                playerItem = CachingPlayerItem(url: url, customFileExtension: "mp4")
            }
            
            playerItem.delegate = self
            var player: DeallocPlayer?
            player = DeallocPlayer(playerItem: playerItem)
            vc.player = player
            player!.automaticallyWaitsToMinimizeStalling = false
            //change before launch
            vc.setValue(true, forKey: "requiresLinearPlayback")
            
            if startTime > 0 {
                player!.seek(to: CMTime(seconds: Double(startTime)+1.0, preferredTimescale: 1))
            }

            self.present(vc, animated:false) {
                vc.player!.play()
            }
            DispatchQueue.global(qos: .background).async {
//                self.addQuestionStops(video: video, vc: vc, player: player!)
                var boundariesSet = false
                while !boundariesSet {
                    if ((vc.player!.currentTime() > CMTime(seconds: Double(startTime) + 0.5, preferredTimescale: 1)) && (vc.player?.error == nil)) {
                        boundariesSet = true
                        self.addQuestionStops(video: video, vc: vc, player: player!)
                    }
                }
            }
//            DispatchQueue.main.async() { [weak player ] in
//                var boundariesSet = false
//                while !boundariesSet {
//                    if ((vc.player!.currentTime() > CMTime(seconds: Double(startTime) + 0.5, preferredTimescale: 1)) && (vc.player?.error == nil)) {
//                        boundariesSet = true
//                        self.addQuestionStops(video: video, vc: vc, player: player!)
//                    }
//                }
//            }
        } else {
            storage?.async.entry(forKey: url.absoluteString, completion: { result in
                let playerItem: CachingPlayerItem
                switch result {
                case .error:
                    // The track is not cached.
                    playerItem = CachingPlayerItem(url: url, customFileExtension: "mp4")
                case .value(let entry):
                    // The track is cached.
                    playerItem = CachingPlayerItem(data: entry.object, mimeType: "video/mp4", fileExtension: "mp4")
                }
                
                playerItem.delegate = self
                var player: DeallocPlayer?
                player = DeallocPlayer(playerItem: playerItem)
                vc.player = player
                player!.automaticallyWaitsToMinimizeStalling = false
                //change before launch
                vc.setValue(true, forKey: "requiresLinearPlayback")
                
                if startTime > 0 {
                    player!.seek(to: CMTime(seconds: Double(startTime)+1.0, preferredTimescale: 1))
                }
                
                self.present(vc, animated:false) {
                    vc.player!.play()
                }
                
                var boundariesSet = false
                while !boundariesSet {
                    if ((vc.player!.currentTime() > CMTime(seconds: Double(startTime) + 0.5, preferredTimescale: 1)) && (vc.player?.error == nil)) {
                        boundariesSet = true
                        DispatchQueue.main.async() { [weak player] in
                            self.addQuestionStops(video: video, vc: vc, player: player!)
                        }
                    }
                }
            })
        }
    }
    
    func addQuestionStops(video: Video, vc: AVPlayerViewController, player: DeallocPlayer) {
        model = Model()
        model?.getVideoQuestions(name: video.name) {[unowned self] result in
            if result != nil {
                let questions = result!
                for (time, index) in video.boundaries {
                    player.boundaryObservers.append(player.addBoundaryTimeObserver(forTimes:[NSValue(time: CMTime(seconds:Double(time), preferredTimescale:1))], queue:.main) { [weak vc, weak player] in
                        player!.pause()
                        self.expandQuestion(question: questions[index], videoIndex: video.index, vc: vc!)
                   })
                }
                player.boundaryObservers.append(player.addBoundaryTimeObserver(forTimes: [NSValue(time: CMTime(seconds: CMTimeGetSeconds(player.currentItem!.asset.duration), preferredTimescale: 1))], queue: .main) { [weak vc] in
                    self.expandSuccess(questions: questions, vc: vc!, video: video)
                })
            }
        }
    }
    
    func expandQuestion(question: Question, videoIndex: Int, vc: AVPlayerViewController) {
        weak var questionOverlay = storyboard?.instantiateViewController(withIdentifier: "QuestionOverlayViewController") as? QuestionOverlayViewController

        questionOverlay!.backingImage = vc.view.makeSnapshot()
        questionOverlay!.question = question
        questionOverlay!.videoIndex = videoIndex
        questionOverlay!.isVidQ = true
        vc.present(questionOverlay!, animated: false)
    }
    
    func expandSuccess(questions: [Question], vc: AVPlayerViewController, video: Video) {
        weak var successOverlay = storyboard?.instantiateViewController(withIdentifier: "SuccessOverlayController") as? SuccessOverlayController
        
        successOverlay!.questions = questions
        successOverlay!.backingImage = vc.view.makeSnapshot()
        successOverlay!.name = video.name.capitalizingFirstLetter()
        successOverlay!.vc = vc
        model?.userFinishedVideo(finishedVideoIndex: video.index)
        videoProgress[video.index] = 6
        collectionView?.reloadData()
        vc.present(successOverlay!, animated: false)
    }

}

extension GalleryController: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        // A track is downloaded. Saving it to the cache asynchronously.
        storage?.async.setObject(data, forKey: playerItem.url.absoluteString, completion: { _ in })
    }
}
