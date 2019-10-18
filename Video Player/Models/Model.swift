//
//  Model.swift
//  Video Player
//
//  Created by Lisa Wang on 4/26/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications

class Model {
    var db: Firestore!
    let settings: FirestoreSettings!
    
    init() {
        db = Firestore.firestore()
        settings = db.settings
        settings.isPersistenceEnabled = true
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    func getVideos(startIndex: Int, completion: @escaping (Array<Video>?) -> ()) {
        let videosRef = db.collection("videos")
        videosRef.order(by: "index").getDocuments() { (querySnapshot, err) in
            if err != nil {
                print("Error getting videos")
                completion(nil); return
            } else {
                var videos = Array<Video>()
                let result = querySnapshot!.documents
                for i in Array(0...result.count - 1) {
                    let index = (startIndex + i) % result.count
                    videos.append(Video(dictionary: result[index].data())!)
                }
                completion(videos)
            }
        }
    }
    
    func getVideoQuestions(name: String, completion: @escaping ([Question]?) -> ()) {
        let questionsRef = db.collection("questions_v3")
        questionsRef.whereField("subject", isEqualTo: name)
            .order(by: "index")
            .getDocuments() { (querySnapshot, error) in
                
                let results = querySnapshot!.documents
                
                if results.count == 0 { completion(nil); return}
                var questions = [Question]()
                for result in results {
                    questions.append(Question(dictionary: result.data())!)
                
                }
                
                completion(questions)
        }
    }
    
    func getTagQuestion(index: Int, tag: String, subject: String, completion: @escaping (Question?) -> ()) {
        let questionsRef = db.collection("questions_v3")
        questionsRef.whereField("tag", isEqualTo: tag)
            .whereField("subject", isEqualTo: subject)
            .whereField("index", isEqualTo: index).limit(to: 1)
            .getDocuments() { (querySnapshot, error) in
                let result = querySnapshot!.documents
                if result.count == 0 { completion(nil); return }
                completion(Question(dictionary: result[0].data())!)
        }
    }
    
    func readTags() -> [[String]] {
        let path = Bundle.main.path(forResource: "/Tags", ofType: "plist")
        let tagDict = NSArray(contentsOfFile: path!)
    
        var returnDict = [[String]]()
        returnDict.append((tagDict?[0] as! Array<String>?)!)
        returnDict.append((tagDict?[1] as! Array<String>?)!)
        returnDict.append((tagDict?[2] as! Array<String>?)!)
        return returnDict
    }
    
    func getUser(completion: @escaping (User) -> ()) {
        let user = Auth.auth().currentUser
        if user != nil {
            // check if users in users_v2, if yes, return, if not create
            db.collection("users_v2").document(user!.uid)
                .getDocument() { (document, error) in
                    if document?.data() == nil {
                        self.createUser(userID: user!.uid, name: "", email: "", targetSubject: "", completion: completion)
                    } else {
                        let result = document?.data()
                        completion(User(dictionary: result!, uid: user!.uid)!)
                    }
            }
        } else {
            Auth.auth().signInAnonymously() { (user, error) in
                if error != nil {
                    return
                } else {
                    self.createUser(userID: user!.user.uid, name: "", email: "", targetSubject: "", completion: completion)
                }
            }
        }
    }
    
    func sendFeedback(feedback: String, userID: String) {
        db?.collection("feedback_v2").addDocument(data: [
            "user": userID,
            "feedback": feedback,
        ])
    }
    
    func getBadges(userID: String, completion: @escaping([Badge]) -> ()) {
        let path = Bundle.main.path(forResource: "/Tags", ofType: "plist")
        let tagDict = NSArray(contentsOfFile: path!)
        let tagDictReading = tagDict![0] as! Array<String>
        let tagDictMath = tagDict![1] as! Array<String>
        let tagDictWriting = tagDict![2] as! Array<String>
        
        var allMath = [Badge](repeating: Badge()!, count:14)
        var allReading = [Badge](repeating: Badge()!, count:13)
        var allWriting = [Badge](repeating: Badge()!, count:15)
        
        var mathBadges = [Badge]()
        var completedMathBadges = [Badge]()
        
        var readingBadges = [Badge]()
        var completedReadingBadges = [Badge]()
        
        var writingBadges = [Badge]()
        var completedWritingBadges = [Badge]()
        
        db.collection("users_v2").document(userID).collection("badges")
            .order(by: "subject")
            .order(by: "tag")
            .getDocuments(){ (querySnapshot, error) in
            
            guard let docs = querySnapshot?.documents else { return }
                for doc in docs {
                    let badge = Badge(dictionary: doc.data())!
                    if badge.subject == "Math" {
                        allMath[tagDictMath.index(of: badge.tag)!] = badge
                    } else if badge.subject == "Reading" {
                        allReading[tagDictReading.index(of: badge.tag)!] = badge
                    } else {
                        allWriting[tagDictWriting.index(of: badge.tag)!] = badge
                    }
                }
                for badge in allMath {
                    if badge.lastIndex == 5 {
                        completedMathBadges.append(badge)
                    } else {
                        mathBadges.append(badge)
                    }
                }
                
                for badge in allReading {
                    if badge.lastIndex == 5 {
                        completedReadingBadges.append(badge)
                    } else {
                        readingBadges.append(badge)
                    }
                }
                
                for badge in allWriting {
                    if badge.lastIndex == 5 {
                        completedWritingBadges.append(badge)
                    } else {
                        writingBadges.append(badge)
                    }
                }

            completion(mathBadges + completedMathBadges + readingBadges + completedReadingBadges + writingBadges + completedWritingBadges)
        }
    }
    
    func createNewAnonUser(name: String, email: String, targetSubject: String, completion: @escaping (User) -> ()) {
        let user = Auth.auth().currentUser
        if user != nil {
            self.createUser(userID: user!.uid, name: name, email: email, targetSubject: targetSubject, completion: completion)
        } else {
            Auth.auth().signInAnonymously() { (user, error) in
                if error != nil {
                    return
                } else {
                    self.createUser(userID: user!.user.uid, name: name, email: email, targetSubject: targetSubject, completion: completion)
                }
            }
        }
    }
    
    func createUser(userID: String, name: String, email: String, targetSubject: String, completion: @escaping (User) -> ()) {
        let tagDict = self.readTags()
        let subjects = ["Reading", "Math", "Writing"]
        let batch = self.db.batch()
        let userRef = self.db.collection("users_v2").document(userID)
        batch.setData([
            "videoIndex": 0,
            "videoProgress": [],
            "minutesPracticed": 0,
            "tagsCompleted": 0,
            "Math": 0,
            "Reading": 0,
            "Writing": 0,
            "targetSubject": targetSubject,
            "lastAnswered": 0,
            "notifications": true,
            "days": [1, 4],
            "time": 16,
            "name": name,
            "email": email
            ], forDocument: userRef)
        for (index, tagArray) in tagDict.enumerated() {
            for tag in tagArray {
                let badgeRef = self.db.collection("users_v2").document(userID).collection("badges").document(tag)
                batch.setData([
                    "tag": tag,
                    "subject": subjects[index],
                    "lastIndex": 0
                    ], forDocument: badgeRef)
            }
        }
        
        batch.commit() { err in
            if err != nil { return } else {
//                DispatchQueue.global(qos: .userInitiated).async {
//                    //self.getNextQuestions(badges: [])
//                }
                
                self.scheduleNotifications(days: [1, 4])
                completion(User(uid: userID, name: name, email: email, targetSubject: targetSubject, days: [1, 4], time: 16)!)
            }
        }
    }
    
    func getNewTargetSubject(math: Int, reading: Int, writing: Int) -> String{
        let minProgress = min(math, reading, writing)
        
        if minProgress == math && math != 70{
            return "Math"
        } else if minProgress == writing && writing != 75 {
            return "Writing"
        } else {
            return "Reading"
        }
    }
    
    func getTotalQuestionCounts(completion: @escaping([String: Int]) -> ()) {
        db.collection("total_questions").document("v2_count").getDocument() { (document, error) in
            var countDict = [String: Int]()
            if error == nil {
                let documentData = document!.data()
                countDict["math"] = documentData!["Math"] as? Int
                countDict["reading"] = documentData!["Reading"] as? Int
                countDict["writing"] = documentData!["Writing"] as? Int
                completion(countDict)
            }
    
        }
    }
    
    func userAnsweredDailyQ(tag: String, index: Int, subject: String, elapsedTime: Int) {
        let userID = Auth.auth().currentUser?.uid
        let increment = FieldValue.increment(Int64(1))
        let userRef = db.collection("users_v2").document(userID!)
        let tagRef = db.collection("users_v2").document(userID!).collection("badges").document(tag)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDoc: DocumentSnapshot
            do {
                try userDoc = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var mathProgress = userDoc.data()?["Math"] as? Int,
                var readingProgress = userDoc.data()?["Reading"] as? Int,
                var writingProgress = userDoc.data()?["Writing"] as? Int,
                let minutesPracticed = userDoc.data()?["minutesPracticed"] as? Int else { return nil
            }
            if subject == "Math" {
                mathProgress += 1
            } else if subject == "Writing" {
                writingProgress += 1
            } else {
                readingProgress += 1
            }
            
            let targetSubject = self.getNewTargetSubject(math: mathProgress, reading: readingProgress, writing: writingProgress)
            
            transaction.updateData(["lastAnswered": Date(),
                              subject: increment,
                              "targetSubject": targetSubject,
                              "minutesPracticed": elapsedTime + minutesPracticed], forDocument: userRef)
            
            transaction.updateData(["lastIndex": increment], forDocument: tagRef)
            
            if index == 4 {
                transaction.updateData(["tagsCompleted": increment], forDocument: userRef)
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("Error updating: \(error)")
            }
        }
    }
    
    func userAnsweredQ(tag: String, index: Int, subject: String, elapsedTime: Int, completion: @escaping() -> ()) {
        let userID = Auth.auth().currentUser?.uid
        let increment = FieldValue.increment(Int64(1))
        let userRef = db.collection("users_v2").document(userID!)
        let tagRef = db.collection("users_v2").document(userID!).collection("badges").document(tag)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDoc: DocumentSnapshot
            do {
                try userDoc = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var mathProgress = userDoc.data()?["Math"] as? Int,
                var readingProgress = userDoc.data()?["Reading"] as? Int,
                var writingProgress = userDoc.data()?["Writing"] as? Int,
                let minutesPracticed = userDoc.data()?["minutesPracticed"] as? Int else { return nil
            }
            if subject == "Math" {
                mathProgress += 1
            } else if subject == "Writing" {
                writingProgress += 1
            } else {
                readingProgress += 1
            }
            
            let targetSubject = self.getNewTargetSubject(math: mathProgress, reading: readingProgress, writing: writingProgress)
            
            transaction.updateData(["lastAnswered": Date(),
                                    subject: increment,
                                    "targetSubject": targetSubject,
                                    "minutesPracticed": elapsedTime + minutesPracticed], forDocument: userRef)
            
            transaction.updateData(["lastIndex": increment], forDocument: tagRef)
            
            if index == 4 {
                transaction.updateData(["tagsCompleted": increment], forDocument: userRef)
            }
            completion()
            return nil
        }) { (object, error) in
            if let error = error {
                print("Error updating: \(error)")
            }
        }
    }
    
    func userAnsweredVideoQ(tag: String, videoIndex: Int, subject: String, elapsedTime: Int) {
        let userID = Auth.auth().currentUser?.uid
        let increment = FieldValue.increment(Int64(1))
        let userRef = db.collection("users_v2").document(userID!)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDoc: DocumentSnapshot
            do {
                try userDoc = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            guard var mathProgress = userDoc.data()?["Math"] as? Int,
                var readingProgress = userDoc.data()?["Reading"] as? Int,
                var writingProgress = userDoc.data()?["Writing"] as? Int,
                let minutesPracticed = userDoc.data()?["minutesPracticed"] as? Int,
                let videoProgress = userDoc.data()?["videoProgress"] as? Array<Int> else { return nil
            }
            
            if videoIndex < videoProgress.count && videoProgress[videoIndex] == 6 {
                return nil
            }
            if subject == "Math" {
                mathProgress += 1
            } else if subject == "Writing" {
                writingProgress += 1
            } else {
                readingProgress += 1
            }
            var newVideoProgress = [Int]()
            if videoIndex >= videoProgress.count {
                newVideoProgress = [Int](repeating: 0, count: videoIndex + 1)
                for (i, v) in videoProgress.enumerated() {
                    newVideoProgress[i] = v
                }
                newVideoProgress[videoIndex] = 1
            } else {
                newVideoProgress = videoProgress
                newVideoProgress[videoIndex] = newVideoProgress[videoIndex] + 1
            }
            
            let targetSubject = self.getNewTargetSubject(math: mathProgress, reading: readingProgress, writing: writingProgress)
            
            transaction.updateData([subject: increment,
                                    "targetSubject": targetSubject,
                                    "minutesPracticed": elapsedTime + minutesPracticed,
                                    "videoProgress": newVideoProgress], forDocument: userRef)
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Error updating: \(error)")
            }
        }
    }
    
    func userFinishedVideo(finishedVideoIndex: Int) {
        let userID = Auth.auth().currentUser?.uid
        let userRef = db.collection("users_v2").document(userID!)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDoc: DocumentSnapshot
            do {
                try userDoc = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let videoIndex = userDoc.data()?["videoIndex"] as? Int,
                let videoProgress = userDoc.data()?["videoProgress"] as? [Int] else { return nil }
            
            var newVideoProgress = videoProgress
            var newVideoIndex = videoIndex
            if videoProgress[finishedVideoIndex] != 6 {
                newVideoProgress[finishedVideoIndex] = 6
                
                if finishedVideoIndex == videoIndex {
                    newVideoIndex += 1
                }
            }
            
            transaction.updateData(["videoIndex": newVideoIndex, "videoProgress": newVideoProgress], forDocument: userRef)
            
            return nil
            
        }) { (object, error) in
            if let error = error {
                print("Error updating: \(error)")
            }
        }
    }
    
    func updateUser(name: String, email: String, notifications: Bool, days: [Int], time: Int) {
        let userID = Auth.auth().currentUser?.uid
        let userRef = db.collection("users_v2").document(userID!)
        
        userRef.updateData(["name": name, "email": email, "notifications": notifications, "days": days, "time": time])
    }
    
    func updateUserEmail(email: String) {
       let userID = Auth.auth().currentUser?.uid
       let userRef = db.collection("users_v2").document(userID!)
        
       userRef.updateData(["email": email])
    }
    
    func scheduleNotifications(days: [Int]) {
        let hour = Int(8)
        let minutes = 0
        
        for day in days {
            scheduleNotification(day: day + 1, hour: hour, minute: minutes)
        }
    }
    
    func scheduleNotification(day: Int, hour: Int, minute: Int) {
        let date = createDate(weekday: day, hour: hour, minute: minute)
        
        let triggerWeekly = Calendar.current.dateComponents([.weekday,.hour,.minute,.second,], from: date)
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Time to Practice"
            content.body = "An almost fun SAT question is ready for you!"
            content.sound = UNNotificationSound.default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
            let request = UNNotificationRequest(identifier: "textNotification" + String(day), content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: {(error) in
                if error != nil {
                }
            })
        } else {
            let notification = UILocalNotification()
            notification.alertTitle = "Time to Practice"
            notification.alertBody = "An almost fun SAT question is ready for you!"
            notification.fireDate = date
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.repeatInterval = NSCalendar.Unit.weekday
            
            UIApplication.shared.scheduledLocalNotifications = [notification]
        }
    }
    
    func createDate(weekday: Int, hour: Int, minute: Int)->Date{
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.weekday = weekday
        components.weekdayOrdinal = 10
        components.timeZone = .current
        
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components)!
    }
}

