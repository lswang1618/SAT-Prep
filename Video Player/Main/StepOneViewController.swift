//
//  StepOneViewController.swift
//  Video Player
//
//  Created by Lisa Wang on 6/20/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit

class StepOneViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var firstTags: UIStackView!
    @IBOutlet weak var secondTags: UIStackView!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var mathButton: OnboardingTopicButton!
    @IBOutlet weak var readingButton: OnboardingTopicButton!
    @IBOutlet weak var writingButton: OnboardingTopicButton!
    @IBOutlet weak var allButton: OnboardingTopicButton!
    
    var email: String?
    var name: String?
    var selectedTag = "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.setCustomSpacing(40, after: headerLabel)
        stackView.setCustomSpacing(10, after: firstTags)
        stackView.setCustomSpacing(60, after: secondTags)
        
        if name == "" {
            thanksLabel.text = "Great, thanks!"
        } else {
            thanksLabel.text = "Great, thanks " + name! + "!"
        }
        
        mathButton.setTitleColor(UIColor.white, for: .highlighted)
        mathButton.selectedColor = UIColor(red:0.96, green:0.66, blue:0.10, alpha:1.0)
        
        readingButton.setTitleColor(UIColor.white, for: .highlighted)
        readingButton.selectedColor = UIColor(red:0.00, green:0.76, blue:0.21, alpha:1.0)
        
        writingButton.setTitleColor(UIColor.white, for: .highlighted)
        writingButton.selectedColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        
        allButton.setTitleColor(UIColor.white, for: .highlighted)
        allButton.selectedColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
    }
    @IBAction func selectMath(_ sender: OnboardingTopicButton) {
        mathButton.backgroundColor = UIColor(red:0.96, green:0.66, blue:0.10, alpha:1.0)
        mathButton.setTitleColor(UIColor.white, for: .normal)
        selectedTag = "Math"
        resetButtons(buttons: [readingButton, writingButton, allButton])
    }
    @IBAction func selectReading(_ sender: OnboardingTopicButton) {
        readingButton.backgroundColor = UIColor(red:0.00, green:0.76, blue:0.21, alpha:1.0)
        readingButton.setTitleColor(UIColor.white, for: .normal)
        selectedTag = "Reading"
        resetButtons(buttons: [mathButton, writingButton, allButton])
    }
    @IBAction func selectWriting(_ sender: OnboardingTopicButton) {
        writingButton.backgroundColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        writingButton.setTitleColor(UIColor.white, for: .normal)
        selectedTag = "Writing"
        resetButtons(buttons: [mathButton, readingButton, allButton])
    }
    
    @IBAction func selectAllTopics(_ sender: OnboardingTopicButton) {
        allButton.backgroundColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0)
        allButton.setTitleColor(UIColor.white, for: .normal)
        selectedTag = "All"
        resetButtons(buttons: [mathButton, writingButton, readingButton])
    }
    
    func resetButtons(buttons: [UIButton]) {
        for button in buttons {
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor.black, for:.normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! StepTwoViewController
        destination.name = name!
        destination.email = email!
        destination.selectedTag = selectedTag
    }
}
