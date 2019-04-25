//
//  ViewController.swift
//  Video Player
//
//  Created by Lisa Wang on 4/24/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    var vc = AVPlayerViewController()
    var asset: AVAsset!
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var timeObserverToken: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    @IBAction func clickPlay(_ sender: UIButton) {
        guard let path = Bundle.main.path(forResource: "MVI_3527", ofType: "mp4") else { return }
        initializeVideo(videoURL: URL(fileURLWithPath: path))
    }
    
    func initializeVideo(videoURL: URL) {
        player = AVPlayer(url: videoURL)
        vc.player = player
        vc.setValue(true, forKey: "requiresLinearPlayback")
        present(vc, animated:true) {
            self.vc.player?.play()
        }
        addBoundaryTimeObserver(times: [2.0])
    }
    
    func addBoundaryTimeObserver(times: [Double]) {
        var boundaries = [NSValue]()
        for i in times {
            boundaries.append(NSValue(time: CMTime(seconds:i, preferredTimescale:1)))
        }
        
        timeObserverToken = player.addBoundaryTimeObserver(forTimes:boundaries, queue:.main) {
            self.vc.player?.pause()
            self.expandQuestion()
        }
    }
    
    func expandQuestion() {
        guard let questionOverlay = storyboard?.instantiateViewController(withIdentifier: "QuestionOverlayViewController") as? QuestionOverlayViewController else {
            assertionFailure("No view controller ID QuestionOverlayViewController in storyboard")
            return
        }
        questionOverlay.backingImage = vc.view.makeSnapshot()
        vc.present(questionOverlay, animated: false)
    }


}

