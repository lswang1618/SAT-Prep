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
    var index: Int?
    
    // question info
    var text: String
    var correctAnswer: Int
    
    // answers
    var answerA: Answer
    var answerB: Answer
    var answerC: Answer
    var answerD: Answer
    
    var content: Content
    var content2: Content?
    var pack: [Question]?
    var packID: String?
    
    var dictionary: [String: Any] {
        return [
            "tag": tag,
            "subject": subject,
            "index": index as Any,
            "text": text,
            "correctAnswer": correctAnswer,
            "answerA": answerA,
            "answerB": answerB,
            "answerC": answerC,
            "answerD": answerD,
            "content": content,
            "content2": content2 as Any,
            "pack": pack as Any,
            "packID": packID as Any
        ]
    }
}

extension Question {
    
    static let subject = [ "Math", "Writing", "Reading"]
    
    init?(dictionary: [String : Any]) {
        guard let tag = dictionary["tag"] as? String,
            let subject = dictionary["subject"] as? String,
            let text = dictionary["text"] as? String,
            let correctAnswer = dictionary["correctAnswer"] as? Int,
            let answerA = Answer(dictionary: dictionary["answerA"] as! [String : Any]),
            let answerB = Answer(dictionary: dictionary["answerB"] as! [String : Any]),
            let answerC = Answer(dictionary: dictionary["answerC"] as! [String : Any]),
            let answerD = Answer(dictionary: dictionary["answerD"] as! [String : Any]),
            let content = Content(dictionary: dictionary["content"] as! [String : Any]) else { return nil }
        
        var packQArray: Array<Question>?
        if let packQs = dictionary["pack"] {
            packQArray = []
            for item in (packQs as? Array<Any>)! {
                packQArray!.append(Question(dictionary: item as! [String : Any])!)
            }
        } else {
            packQArray = nil
        }
        
        var content2: Content?
        if let value = dictionary["content2"] {
            content2 = Content(dictionary: value as! [String : Any])
        } else {
            content2 = nil
        }
        
        var index: Int?
        if dictionary["index"] != nil {
            index = (dictionary["index"] as! Int)
        } else {
            index = nil
        }
        
        var packID: String?
        if dictionary["packID"] != nil {
            packID = (dictionary["packID"] as! String)
        } else {
            packID = nil
        }
        
        self.init(tag: tag,
                  subject: subject,
                  index: index,
                  text: text,
                  correctAnswer: correctAnswer,
                  answerA: answerA,
                  answerB: answerB,
                  answerC: answerC,
                  answerD: answerD,
                  content: content,
                  content2: content2,
                  pack: packQArray,
                  packID: packID
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
        
        var explanationArray: Array<Explanation> = []
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
    var storyID: String?
    
    var dictionary: [String : Any] {
        return [
            "main": main,
            "image": image,
            "intro": intro,
            "labels": labels,
            "title": title,
            "useLabels": useLabels,
            "storyID": storyID as Any
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
        
        if let storyID = dictionary["storyID"] {
            self.init(main: main, image: image, intro: intro, labels: labels, title: title, useLabels: useLabels, storyID: (storyID as! String))
        } else {
            self.init(main: main, image: image, intro: intro, labels: labels, title: title, useLabels: useLabels, storyID: "")
        }
        
    }
}

struct Story {
    var pages: Array<Page>
    
    var dictionary: [String : Any] {
        return [
            "pages": pages
        ]
    }
}

extension Story {
    init?(dictionary: [String : Any]) {
        guard let pages = dictionary["pages"] as? Array<Any> else { return nil }
        
        var pageArray: Array<Page>
        pageArray = []
        for item in pages {
            pageArray.append(Page(dictionary: item as! [String : Any])!)
        }
        
        self.init(pages: pageArray)
    }
}

struct Page {
    var image: String
    var text: String
    var title: String
    var link: String
    var linkText: String
    
    var dictionary: [String : Any] {
        return [
            "image": image,
            "title": title,
            "text": text,
            "link": link,
            "linkText": linkText
        ]
    }
}

extension Page {
    init?(dictionary: [String : Any]) {
        guard let image = dictionary["image"] as? String,
            let title = dictionary["title"] as? String,
            let text = dictionary["text"] as? String,
            let link = dictionary["link"] as? String,
            let linkText = dictionary["linkText"] as? String else { return nil }
        
        self.init(image: image, text: text, title: title, link: link, linkText: linkText)
    }
}










