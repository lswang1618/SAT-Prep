//
//  User.swift
//  SAT Prep
//
//  Created by Lisa Wang on 5/31/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import Foundation

struct User {
    var uid: String
    var index: Int
    var last_answered: Any
    var streak: Int
    
    var dictionary: [String: Any] {
        return [
            "uid": uid,
            "index": index,
            "last_answered": last_answered,
            "streak": streak
        ]
    }
}

extension User {
    init?(dictionary: [String : Any], uid: String) {
        guard let uid = uid as String?,
            let index = dictionary["qIndex"] as? Int,
            let last_answered = dictionary["last_answered"] as Any?,
            let streak = dictionary["streak"] as? Int else { return nil}
        
        self.init(uid: uid, index: index, last_answered: last_answered, streak: streak)
    }
    init?(uid: String) {
        self.init(uid: uid, index: 0, last_answered: 0, streak: 0)
    }
}

struct Badge {
    var tag: String
    var progress: Int
    var progressLevel1: Int
    var progressLevel2: Int
    var progressLevel3: Int
}

extension Badge {
    init?(dictionary: [String: Any]) {
        guard let tag = dictionary["tag"] as? String,
            let progress = dictionary["progress"] as? Int,
            let progressLevel1 = dictionary["progressLevel1"] as? Int,
            let progressLevel2 = dictionary["progressLevel2"] as? Int,
            let progressLevel3 = dictionary["progressLevel3"] as? Int else { return nil }
        
        self.init(tag: tag, progress: progress, progressLevel1: progressLevel1, progressLevel2: progressLevel2, progressLevel3: progressLevel3)
    }
    
    init?() {
        self.init(tag: "", progress: 0, progressLevel1: 0, progressLevel2: 0, progressLevel3: 0)
    }
}
