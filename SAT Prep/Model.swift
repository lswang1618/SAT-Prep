//
//  Model.swift
//  SAT Prep
//
//  Created by Lisa Wang on 5/25/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import Foundation
import Firebase

class Model {
    var db: Firestore!
    let settings: FirestoreSettings!
    let tags = ["Linear Equations", "Development", "Analyzing Word Choice", "Linear Inequalities", "Organization", "Analyzing Text Structure", "Rates, Ratios, and Proportions", "Effective Language Use", "Analyzing Point of View", "Scatterplots", "Sentence Structure", "Analyzing Purpose", "Statistics and Probability", "Conventions of Usage", "Analyzing Arguments", "Polynomials and Rational Expressions", "Conventions of Punctuations", "Reading Closely", "Functions", "Citing Textual Evidence", "Quadratic Equations", "Central Ideas and Themes", "Imaginary Numbers", "Summarizing", "Lines, Angles, and Triangles", "Understanding Relationships", "Circles", "Interpreting Words and Phrases", "3D Shapes", "Analyzing Multiple Texts", "Trigonometry", "Quantitative Information"]
    
    init() {
        db = Firestore.firestore()
        settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    func readTags() -> [String: Array<String>] {
        let path = Bundle.main.path(forResource: "/Tags", ofType: "plist")
        let tagDict = NSDictionary(contentsOfFile: path!)
        var returnDict = [String: Array<String>]()
        returnDict["reading"] = tagDict?["Reading"] as! Array<String>?
        returnDict["writing"] = tagDict?["Writing"] as! Array<String>?
        returnDict["math"] = tagDict?["Math"] as! Array<String>?
        return returnDict
    }
    
    func getBadges(completion: @escaping([Badge]) -> ()) {
        let user = Auth.auth().currentUser
        var badges = [Badge]()
        
        db.collection("users").document(user!.uid).collection("badges").getDocuments() { (querySnapshot, error) in
            guard let docs = querySnapshot?.documents else { return }
            for doc in docs {
                badges.append(Badge(dictionary: doc.data())!)
            }
            completion(badges)
        }
    }
    
    func getUser(completion: @escaping (User) -> ()) {
//        do {
//            try Auth.auth().signOut()
//        } catch {
//            
//        }
        let user = Auth.auth().currentUser
        
        let tagDict = self.readTags()
        let tagArray = tagDict["reading"]! as [String] + tagDict["writing"]! + tagDict["math"]!
        if user != nil {
            db.collection("users").document(user!.uid)
                .getDocument() { (document, error) in
                    guard let result = document?.data() else { return }
                    completion(User(dictionary: result, uid: user!.uid)!)
            }
        } else {
            Auth.auth().signInAnonymously() { (user, error) in
                if error != nil {
                    return
                } else {
                    let batch = self.db.batch()
                    let userRef = self.db.collection("users").document(user!.user.uid)
                    batch.setData([
                        "qIndex": 0,
                        "streak": 0,
                        "last_answered": 0,
                        "days": [],
                        "time": 0,
                        "name": "",
                        "profileImage": ""
                    ], forDocument: userRef)
                    for tag in tagArray {
                        let badgeRef = self.db.collection("users").document(user!.user.uid).collection("badges").document(tag)
                        batch.setData([
                            "tag": tag,
                            "progress": 0,
                            "lastIndex": 0
                            ], forDocument: badgeRef)
                    }
                    batch.commit() { err in
                        if err != nil { return } else {
                            completion(User(uid: user!.user.uid)!)
                        }
                    }
                }
            }
        }
    }
        
    func getQuestion(tIndex: Int, qIndex: Int, completion: @escaping (Question) -> ()) {
        let questionsRef = db.collection("questions")
        questionsRef.whereField("tag", isEqualTo: tags[tIndex])
            .whereField("index", isGreaterThan: qIndex).limit(to: 1)
            .getDocuments() { (querySnapshot, error) in
                guard let result = Question(dictionary: querySnapshot!.documents[0].data()) else { return }
                completion(result)
        }
    }
    
    func getTagQuestion(qIndex: Int, tag: String, completion: @escaping (Question) -> ()) {
        let questionsRef = db.collection("questions")
        
        questionsRef.whereField("tag", isEqualTo: tag)
            .whereField("index", isGreaterThan: qIndex).limit(to: 1)
            .getDocuments() { (querySnapshot, error) in
                
                guard let result = Question(dictionary: querySnapshot!.documents[0].data()) else { return }
                completion(result)
        }
    }
    
    func checkStreak(user: User) -> Int {
        let date = user.last_answered
        let calendar = Calendar.current
        let today = Date()
        
        if date as? Int != 0 {
            let dict = date as AnyObject,
            d = dict.dateValue()
            let last_year = calendar.component(.year, from: d),
            last_month = calendar.component(.month, from: d),
            last_day = calendar.component(.day, from: d),
            today_year = calendar.component(.year, from: today),
            today_month = calendar.component(.month, from: today),
            today_day = calendar.component(.day, from: today),
            next_date = Calendar.current.date(byAdding: .day, value: 1, to: d)! as Date,
            next_year = calendar.component(.year, from: next_date),
            next_month = calendar.component(.month, from: next_date),
            next_day = calendar.component(.day, from: next_date)
            
            if (last_year == today_year && last_month == today_month && last_day == today_day){
                return 0
            } else if (today_year == next_year && today_month == next_month && today_day == next_day){
                return 1
            } else {
                let ref = db.collection("users").document(user.uid)
                ref.updateData([
                    "streak": 0
                ])
                return 1
            }
        }
        else {
            return 1
        }
    }
    
    func merge(dictA: [String : Any], dictB: [String : Any]) -> [String : Any] {
        var result = [String : Any]()
        for (k, v) in dictA {
            result[k] = v
        }
        
        for (i, j) in dictB {
            result[i] = j
        }
        return result
    }
}
