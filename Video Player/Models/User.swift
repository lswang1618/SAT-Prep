//
//  User.swift
//  Video Player
//
//  Created by Lisa Wang on 6/9/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation

struct User {
    var uid: String
    var videoIndex: Int
    var videoProgress: Array<Int>
    var minutesPracticed: Int
    var tagsCompleted: Int
    var Math: Int
    var Reading: Int
    var Writing: Int
    var targetSubject: String
    var lastAnswered: Any
    var notifications: Bool
    var days: Array<Int>
    var time: Int
    var name: String
    var email: String
    
    var dictionary: [String: Any] {
        return [
            "uid": uid,
            "videoIndex": videoIndex,
            "videoProgress": videoProgress,
            "minutesPracticed": minutesPracticed,
            "tagsCompleted": tagsCompleted,
            "Math": Math,
            "Reading": Reading,
            "Writing": Writing,
            "targetSubject": targetSubject,
            "lastAnswered": lastAnswered,
            "notifications": notifications,
            "days": days,
            "time": time,
            "name": name,
            "email": email
        ]
    }
}

extension User {
    init?(dictionary: [String : Any], uid: String) {
        guard let uid = uid as String?,
            let videoIndex = dictionary["videoIndex"] as? Int,
            let videoProgress = dictionary["videoProgress"] as? Array<Int>,
            let minutesPracticed = dictionary["minutesPracticed"] as? Int,
            let tagsCompleted = dictionary["tagsCompleted"] as? Int,
            let Math = dictionary["Math"] as? Int,
            let Reading = dictionary["Reading"] as? Int,
            let Writing = dictionary["Writing"] as? Int,
            let targetSubject = dictionary["targetSubject"] as? String,
            let lastAnswered = dictionary["lastAnswered"] as? Any,
            let notifications = dictionary["notifications"] as? Bool,
            let days = dictionary["days"] as? Array<Int>,
            let time = dictionary["time"] as? Int,
            let name = dictionary["name"] as? String,
            let email = dictionary["email"] as? String else { return nil}
        
        self.init(uid: uid, videoIndex: videoIndex, videoProgress: videoProgress, minutesPracticed: minutesPracticed, tagsCompleted: tagsCompleted, Math: Math, Reading: Reading, Writing: Writing, targetSubject: targetSubject, lastAnswered: lastAnswered, notifications: notifications, days: days, time: time, name: name, email: email)
    }
    
//    init?(uid: String) {
//        self.init(uid: uid, videoIndex: 0, videoProgress: [], minutesPracticed: 0, tagsCompleted: 0, Math: 0, Reading: 0, Writing: 0, targetSubject: "All", lastAnswered: 0, notifications: true, days: [], time: 0, name: "", email: "")
//    }
    
    init?(uid: String, name: String, email: String, targetSubject: String, days: [Int], time: Int) {
        self.init(uid: uid, videoIndex: 0, videoProgress: [], minutesPracticed: 0, tagsCompleted: 0, Math: 0, Reading: 0, Writing: 0, targetSubject: targetSubject, lastAnswered: 0, notifications: true, days: days, time: time, name: name, email: email)
    }
}

struct Badge {
    var tag: String
    var subject: String
    var lastIndex: Int
}

extension Badge {
    init?(dictionary: [String: Any]) {
        guard let tag = dictionary["tag"] as? String,
            let subject = dictionary["subject"] as? String,
            let lastIndex = dictionary["lastIndex"] as? Int else { return nil }
        
        self.init(tag: tag, subject: subject, lastIndex: lastIndex)
    }
    
    init?() {
        self.init(tag: "", subject: "", lastIndex: 0)
    }
    
    mutating func update(index: Int) {
        self.lastIndex = index
    }
}
