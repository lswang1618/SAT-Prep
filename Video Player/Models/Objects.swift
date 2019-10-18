//
//  Objects.swift
//  Video Player
//
//  Created by Lisa Wang on 4/26/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation


struct Question {
    // question type
    var tag: String
    var subject: String
    var index: Int
    
    // question info
    var text: String
    var correctAnswer: Int
    var answerSteps: Array<Explanation>
    
    // answers
    var answerA: Answer
    var answerB: Answer
    var answerC: Answer
    var answerD: Answer
    
    var content: Content
    var content2: Content?
    var topic: String?
    
    var dictionary: [String: Any] {
        return [
            "tag": tag,
            "subject": subject,
            "index": index,
            "text": text,
            "correctAnswer": correctAnswer,
            "answerSteps": answerSteps,
            "answerA": answerA,
            "answerB": answerB,
            "answerC": answerC,
            "answerD": answerD,
            "content": content,
            "content2": content2 as Any,
            "topic": topic as Any
        ]
    }
}

extension Question {
    init?(dictionary: [String : Any]) {
        guard let tag = dictionary["tag"] as? String,
            let subject = dictionary["subject"] as? String,
            let index = dictionary["index"] as? Int,
            let text = dictionary["text"] as? String,
            let correctAnswer = dictionary["correctAnswer"] as? Int,
            let answerSteps = dictionary["answer_steps"] as? Array<Any>,
            let answerA = Answer(dictionary: dictionary["answerA"] as! [String : Any]),
            let answerB = Answer(dictionary: dictionary["answerB"] as! [String : Any]),
            let answerC = Answer(dictionary: dictionary["answerC"] as! [String : Any]),
            let answerD = Answer(dictionary: dictionary["answerD"] as! [String : Any]),
            let content = Content(dictionary: dictionary["content"] as! [String : Any]) else { return nil }
        
        var explanationArray: Array<Explanation> = []
        for item in answerSteps {
            explanationArray.append(Explanation(dictionary: item as! [String : Any])!)
        }
        
        var content2: Content?
        if let value = dictionary["content2"] {
            content2 = Content(dictionary: value as! [String : Any])
        } else {
            content2 = nil
        }
        
        var topic: String?
        if dictionary["topic"] != nil {
            topic = (dictionary["topic"] as! String)
        } else {
            topic = nil
        }
        
        self.init(tag: tag,
                  subject: subject,
                  index: index,
                  text: text,
                  correctAnswer: correctAnswer,
                  answerSteps: explanationArray,
                  answerA: answerA,
                  answerB: answerB,
                  answerC: answerC,
                  answerD: answerD,
                  content: content,
                  content2: content2,
                  topic: topic
        )
    }
    
}

struct Answer {
    var choiceText: String
    var explanations: Array<Explanation>
    
    var dictionary: [String: Any] {
        return [
            "choiceText": choiceText,
            "explanations": explanations        ]
    }
}

extension Answer {
    init?(dictionary: [String : Any]) {
        guard let choiceText = dictionary["choiceText"] as? String,
            let explanations = dictionary["explanations"] as? Array<Any> else { return nil }
        
        var explanationArray: Array<Explanation> = []
        for item in explanations {
            explanationArray.append(Explanation(dictionary: item as! [String : Any])!)
        }
        
        self.init(choiceText: choiceText, explanations: explanationArray)
    }
}


struct Content {
    var main: Array<String>
    var image: String
    var intro: String
    var labels: Array<Int>
    var title: String
    var useLabels: Bool
    var movie: Bool
    
    var dictionary: [String : Any] {
        return [
            "main": main,
            "image": image,
            "intro": intro,
            "labels": labels,
            "title": title,
            "useLabels": useLabels,
            "movie": movie
        ]
    }
}

extension Content {
    init?(dictionary: [String : Any]) {
        guard let main = dictionary["main"] as? Array<String>,
            let image = dictionary["image"] as? String,
            let intro = dictionary["intro"] as? String,
            let labels = dictionary["labels"] as? Array<Int>,
            let title = dictionary["title"] as? String,
            let useLabels = dictionary["useLabels"] as? Bool else { return nil }
        
        var movie: Bool
        if let value = dictionary["movie"] {
            movie = value as! Bool
        } else {
            movie = false
        }
        
        self.init(main: main, image: image, intro: intro, labels: labels, title: title, useLabels: useLabels, movie: movie)
        
    }
}

struct Explanation {
    var explanationText: String
    var choiceA: String
    var choiceB: String
    var correctChoice: Int
    var quote: String
    
    var dictionary: [String: Any] {
        return [
            "explanationText": explanationText,
            "choiceA": choiceA,
            "choiceB": choiceB,
            "correctChoice": correctChoice,
            "quote": quote
        ]
    }
}

extension Explanation {
    init?(dictionary: [String : Any]) {
        guard let explanationText = dictionary["explanationText"] as? String,
            let choiceA = dictionary["choiceA"] as? String,
            let choiceB = dictionary["choiceB"] as? String,
            let correctChoice = dictionary["correctChoice"] as? Int,
            let quote = dictionary["quote"] as? String else { return nil }
        
        self.init(explanationText: explanationText, choiceA: choiceA, choiceB: choiceB, correctChoice: correctChoice, quote: quote)
    }
}

struct Video {
    var name: String
    var index: Int
    var boundaries: Array<(Int, Int)>
    var url: String
    var title: String
    var subTitle: String
    var snap: String
}

extension Video {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
            let index = dictionary["index"] as? Int,
            let url = dictionary["url"] as? String,
            let subTitle = dictionary["subTitle"] as? String,
            let title = dictionary["title"] as? String,
            let snap = dictionary["snap"] as? String else { return nil }
        
        var boundaries = Array<(Int, Int)>()
        if dictionary["boundaries"] != nil {
            for item in (dictionary["boundaries"] as? Array<[String : Int]>)! {
                boundaries.append((item["time"]!, item["index"]!))
            }
        }
        self.init(name: name, index: index, boundaries: boundaries, url: url, title: title, subTitle: subTitle, snap: snap)
    }
}











