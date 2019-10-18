//
//  DeallocPlayer.swift
//  Video Player
//
//  Created by Lisa Wang on 7/6/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import AVFoundation

class DeallocPlayer: AVPlayer {
    var boundaryObservers = [Any]()
    
    deinit {
        for token in boundaryObservers {
            //removeTimeObserver(token)
        }
    }
}
