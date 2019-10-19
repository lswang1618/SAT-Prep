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
    var days: Array<Int>
    var time: Int
    var name: String
    var profileImage: String
    
    var dictionary: [String: Any] {
        return [
            "uid": uid,
            "index": index,
            "last_answered": last_answered,
            "streak": streak,
            "days": days,
            "time": time,
            "name": name,
            "profileImage": profileImage
        ]
    }
}

extension User {
    init?(dictionary: [String : Any], uid: String) {
        guard let uid = uid as String?,
            let index = dictionary["qIndex"] as? Int,
            let last_answered = dictionary["last_answered"] as Any?,
            let streak = dictionary["streak"] as? Int,
            let days = dictionary["days"] as? Array<Int>,
            let time = dictionary["time"] as? Int,
            let name = dictionary["name"] as? String,
            let profileImage = dictionary["profileImage"] as? String else { return nil}
        
        self.init(uid: uid, index: index, last_answered: last_answered, streak: streak, days: days, time: time, name: name, profileImage: profileImage)
    }
    init?(uid: String) {
        self.init(uid: uid, index: 0, last_answered: 0, streak: 0, days: [], time: 36, name: "", profileImage: "")
    }
}

struct Badge {
    var tag: String
    var progress: Int
    var lastIndex: Int
}

extension Badge {
    init?(dictionary: [String: Any]) {
        guard let tag = dictionary["tag"] as? String,
            let progress = dictionary["progress"] as? Int,
            let lastIndex = dictionary["lastIndex"] as? Int else { return nil }
        
        self.init(tag: tag, progress: progress, lastIndex: lastIndex)
    }
    
    init?() {
        self.init(tag: "", progress: 0, lastIndex: 0)
    }
    
    mutating func update(index: Int) {
        self.lastIndex = index
        self.progress += 1
    }
}
