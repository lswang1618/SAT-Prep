//
//  Question.swift
//  SAT Prep
//
//  Created by Lisa Wang on 5/16/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
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
    
    // answers
    var answerA: Answer
    var answerB: Answer
    var answerC: Answer
    var answerD: Answer
    
    var content: Content
    
    var dictionary: [String: Any] {
        return [
            "tag": tag,
            "subject": subject,
            "index": index,
            "text": text,
            "correctAnswer": correctAnswer,
            "answerA": answerA,
            "answerB": answerB,
            "answerC": answerC,
            "answerD": answerD,
            "content": content
        ]
    }
}

extension Question {
    
    static let subject = [ "Math", "Writing", "Reading"]
    
    init?(dictionary: [String : Any]) {
        guard let tag = dictionary["tag"] as? String,
            let subject = dictionary["subject"] as? String,
            let index = dictionary["index"] as? Int,
            let text = dictionary["text"] as? String,
            let correctAnswer = dictionary["correctAnswer"] as? Int,
            let answerA = Answer(dictionary: dictionary["answerA"] as! [String : Any]),
            let answerB = Answer(dictionary: dictionary["answerB"] as! [String : Any]),
            let answerC = Answer(dictionary: dictionary["answerC"] as! [String : Any]),
            let answerD = Answer(dictionary: dictionary["answerD"] as! [String : Any]),
            let content = Content(dictionary: dictionary["content"] as! [String : Any]) else { return nil }
        
        self.init(tag: tag,
                  subject: subject,
                  index: index,
                  text: text,
                  correctAnswer: correctAnswer,
                  answerA: answerA,
                  answerB: answerB,
                  answerC: answerC,
                  answerD: answerD,
                  content: content
        )
    }
    
}

struct Answer {
    var choiceText: String
    var explanations: Array<Explanation>
    
    var dictionary: [String: Any] {
        return [
            "choiceText": choiceText,
            "explanations": explanations
        ]
    }
}

extension Answer {
    init?(dictionary: [String : Any]) {
        guard let choiceText = dictionary["choiceText"] as? String,
            let explanations = dictionary["explanations"] as? Array<Any> else { return nil }
        
        var explanationArray: Array<Explanation>
        explanationArray = []
        for item in explanations {
             explanationArray.append(Explanation(dictionary: item as! [String : Any])!)
        }
        
        self.init(choiceText: choiceText, explanations: explanationArray)
    }
}

struct Explanation {
    var explanationText: String
    var choiceA: String
    var choiceB: String
    var correctChoice: Int
    
    var dictionary: [String: Any] {
        return [
            "explanationText": explanationText,
            "choiceA": choiceA,
            "choiceB": choiceB,
            "correctChoice": correctChoice
        ]
    }
}

extension Explanation {
    init?(dictionary: [String : Any]) {
        guard let explanationText = dictionary["explanationText"] as? String,
            let choiceA = dictionary["choiceA"] as? String,
            let choiceB = dictionary["choiceB"] as? String,
            let correctChoice = dictionary["correctChoice"] as? Int else { return nil }
        
        self.init(explanationText: explanationText, choiceA: choiceA, choiceB: choiceB, correctChoice: correctChoice)
    }
}

struct Content {
    var main: Array<String>
    var image: String
    var intro: String
    var labels: Array<Int>
    var title: String
    var useLabels: Bool
    
    var dictionary: [String : Any] {
        return [
            "main": main,
            "image": image,
            "intro": intro,
            "labels": labels,
            "title": title,
            "useLabels": useLabels
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
        
        self.init(main: main, image: image, intro: intro, labels: labels, title: title, useLabels: useLabels)
    }
}


