//
//  Settings.swift
//  Video Player
//
//  Created by Lisa Wang on 6/23/19.
//  Copyright © 2019 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications


class SettingsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var timeInput: UITextField!
    
    @IBOutlet weak var basicsLabel: EdgeInsetLabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var notificationsLabel: EdgeInsetLabel!
    @IBOutlet weak var remindersLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    var picker = UIPickerView()
    var pickerData = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"], ["00", "30"], ["AM", "PM"]]
    var user: User?
    var selectedDays = [Int]()
    var time = 0
    var brandBlue = UIColor(red:0.20, green:0.40, blue:1.00, alpha:1.0)
    var notificationsOff = false
    var userNotificationSetting = false
    var changed = false {
        didSet {
            changeClose()
        }
    }
    
    @IBAction func toggleSunday(_ sender: UIButton) {
        toggleDate(button: sender, index: 0)
    }
    @IBAction func toggleMonday(_ sender: UIButton) {
        toggleDate(button: sender, index: 1)
    }
    @IBAction func toggleTuesday(_ sender: UIButton) {
        toggleDate(button: sender, index: 2)
    }
    @IBAction func toggleWednesday(_ sender: UIButton) {
        toggleDate(button: sender, index: 3)
    }
    @IBAction func toggleThursday(_ sender: UIButton) {
        toggleDate(button: sender, index: 4)
    }
    @IBAction func toggleFriday(_ sender: UIButton) {
        toggleDate(button: sender, index: 5)
    }
    @IBAction func toggleSaturday(_ sender: UIButton) {
        toggleDate(button: sender, index: 6)
    }
    
    @IBAction func toggleNotificationSwitch(_ sender: UISwitch) {
        userNotificationSetting = !userNotificationSetting
        if userNotificationSetting && notificationsOff{
            DispatchQueue.main.async {
                self.notificationSwitch.isOn = !self.notificationsOff && self.userNotificationSetting
                if self.notificationsOff && self.userNotificationSetting {
                    self.userNotificationSetting = !self.userNotificationSetting
                    let alertController = UIAlertController(title: "Couldn't Enable Notifications", message: "You need to enable notifications for Almost Fun SAT in the Settings app", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "Settings", style: .default) { (action:UIAlertAction) in
                        if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
                        }
                    }
                    
                    let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                    }
                    
                    alertController.addAction(action1)
                    alertController.addAction(action2)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else if !notificationsOff{
            checkForChange()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let fontSize = UIScreen.main.bounds.height * 0.02
        
        basicsLabel.font = basicsLabel.font.withSize(fontSize)
        nameLabel.font = nameLabel.font.withSize(fontSize)
        nameField.font = nameField.font!.withSize(fontSize)
        emailLabel.font = emailLabel.font.withSize(fontSize)
        emailField.font = emailField.font!.withSize(fontSize)
        notificationsLabel.font = notificationsLabel.font.withSize(fontSize)
        remindersLabel.font = remindersLabel.font.withSize(fontSize)
        daysLabel.font = daysLabel.font.withSize(fontSize)
        timeLabel.font = timeLabel.font.withSize(fontSize)
        timeInput.font = timeInput.font!.withSize(fontSize)
        
        sundayButton.titleLabel?.font = sundayButton.titleLabel!.font.withSize(fontSize)
        mondayButton.titleLabel?.font = mondayButton.titleLabel!.font.withSize(fontSize)
        tuesdayButton.titleLabel?.font = tuesdayButton.titleLabel!.font.withSize(fontSize)
        wednesdayButton.titleLabel?.font = wednesdayButton.titleLabel!.font.withSize(fontSize)
        thursdayButton.titleLabel?.font = thursdayButton.titleLabel!.font.withSize(fontSize)
        fridayButton.titleLabel?.font = fridayButton.titleLabel!.font.withSize(fontSize)
        saturdayButton.titleLabel?.font = saturdayButton.titleLabel!.font.withSize(fontSize)
        
        closeButton.titleLabel?.font = closeButton.titleLabel!.font.withSize(fontSize)
    }
    
    override func viewDidLoad() {
        closeButton.imageView?.contentMode = .scaleAspectFit
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        nameField.delegate = self
        emailField.delegate = self
        timeInput.delegate = self
        picker.delegate = self
        timeInput.inputView = picker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = brandBlue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "DONE", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.picked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "CANCEL", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelled))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        timeInput.inputAccessoryView = toolBar
        
        nameField.text = user?.name
        emailField.text = user?.email
        selectedDays = user!.days
        time = user!.time
        layoutButtons()
        calculateTime()
        
        userNotificationSetting = user!.notifications
        checkNotificationSetting()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(checkNotificationSetting), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        checkForChange()
    }
    
    @objc func picked() {
        let newTime = pickerData[0][picker.selectedRow(inComponent: 0)] + ":" + pickerData[1][picker.selectedRow(inComponent: 1)] + " " + pickerData[2][picker.selectedRow(inComponent: 2)]
        timeInput.text = newTime
        time = Int(pickerData[0][picker.selectedRow(inComponent: 0)])! * 2 + Int(pickerData[1][picker.selectedRow(inComponent: 1)])! / 30
        
        if pickerData[2][picker.selectedRow(inComponent: 2)] == "PM" && pickerData[0][picker.selectedRow(inComponent: 0)] != "12" {
            time += 24
        }
        
        if picker.selectedRow(inComponent: 0) == 0 && picker.selectedRow(inComponent: 1) == 0 && picker.selectedRow(inComponent: 2) == 0 {
            time = 0
        }
        
        if picker.selectedRow(inComponent: 0) == 0 && picker.selectedRow(inComponent: 1) == 1 && picker.selectedRow(inComponent: 2) == 0 {
            time = 1
        }
        
        checkForChange()
        self.view.endEditing(true)
    }
    
    @objc func cancelled() {
        self.view.endEditing(true)
    }
    
    func changeClose() {
        if changed == true {
            closeButton.setImage(UIImage(), for: .normal)
            closeButton.setTitle("SAVE", for: .normal)
        } else {
            closeButton.setImage(UIImage(named: "Close"), for: .normal)
            closeButton.setTitle("", for: .normal)
        }
    }
    
    func checkForChange() {
        if user!.name == nameField.text && user!.email == emailField.text && user!.notifications == userNotificationSetting && user!.days == selectedDays && user!.time == time {
            changed = false
        } else {
            changed = true
        }
    }
    
    func calculateTime() {
        var hour = ""
        var minutes = ""
        var ampm = ""
        if time < 2{
            hour = "12"
            let intMinute = user!.time % 2
            minutes = intMinute == 0 ? "00" : "30"
            ampm = " AM"
            
            picker.selectRow(11, inComponent: 0, animated: false)
            picker.selectRow(intMinute, inComponent: 1, animated: false)
            picker.selectRow(0, inComponent: 2, animated: false)
        } else if time <= 25 {
            let intHour = Int(floor(Double(user!.time) / 2.0))
            hour = String(intHour)
            
            let intMinute = user!.time % 2
            minutes = intMinute == 0 ? "00" : "30"
            ampm = " AM"
            
            picker.selectRow(intHour - 1, inComponent: 0, animated: false)
            picker.selectRow(intMinute, inComponent: 1, animated: false)
            picker.selectRow(0, inComponent: 2, animated: false)
        } else {
            let intHour = Int(floor(Double(user!.time - 24) / 2.0))
            hour = String(intHour)
            
            let intMinute = user!.time % 2
            minutes = intMinute == 0 ? "00" : "30"
            ampm = " PM"
            
            picker.selectRow(intHour - 1, inComponent: 0, animated: false)
            picker.selectRow(intMinute, inComponent: 1, animated: false)
            picker.selectRow(1, inComponent: 2, animated: false)
        }
        
        timeInput.text = hour + ":" + minutes + ampm
    }
    
    func layoutButtons() {
        let dayButtons = [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton]
        for button in dayButtons {
            button!.layer.masksToBounds = true
            button!.layer.cornerRadius = button!.frame.width/2.0 - 1
        }
        
        for day in selectedDays {
            dayButtons[day]!.backgroundColor = brandBlue
            dayButtons[day]!.tintColor = UIColor.white
        }
    }
    
    func toggleDate(button: UIButton, index: Int) {
        if selectedDays.contains(index) {
            button.backgroundColor = UIColor.white
            button.tintColor = brandBlue
            selectedDays.removeAll(where: { $0 == index } )
        } else {
            button.backgroundColor = brandBlue
            button.tintColor = UIColor.white
            selectedDays.append(index)
        }
        checkForChange()
    }
    
    @objc func checkNotificationSetting() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings(){ [unowned self] (settings) in
                switch settings.notificationCenterSetting{
                case .enabled:
                    self.notificationsOff = false
                case .disabled:
                    self.notificationsOff = true
                case .notSupported:
                    self.notificationsOff = true
                }
                
                self.toggleView()
            }
        } else {
            if UIApplication.shared.isRegisteredForRemoteNotifications {
                self.notificationsOff = false
            } else {
                notificationsOff = true
            }
            toggleView()
        }
        
    }
    
    func toggleView() {
        DispatchQueue.main.async {
            self.notificationSwitch.isOn = !self.notificationsOff && self.userNotificationSetting
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == timeInput {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            emailField.becomeFirstResponder()
            checkForChange()
            return false
        }
        if textField == emailField {
            checkForChange()
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameField || textField == emailField {
            checkForChange()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 60.0
    }
    
    @IBAction func pressClose(_ sender: UIButton) {
        if changed {
            let model = Model()
            model.updateUser(name: nameField.text!, email: emailField.text!, notifications: userNotificationSetting, days: selectedDays, time: time)
            
            scheduleNotifications()
        }
        user!.name = nameField.text!
        user!.email = emailField.text!
        user!.notifications = userNotificationSetting
        user!.days = selectedDays
        user!.time = time
        
        let tabVC = self.presentingViewController as! CustomTabBarViewController
        let profileVC = tabVC.children[1] as! ProfileViewController
        profileVC.user = user!
        
        self.dismiss(animated: true)
    }
    
    func scheduleNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
        
        if userNotificationSetting {
            let hour = Int(floor(Double(time)/2.0))
            let minutes = 30 * (time % 2)
            
            for day in selectedDays {
                scheduleNotification(day: day + 1, hour: hour, minute: minutes)
            }
        }
    }
    
    func scheduleNotification(day: Int, hour: Int, minute: Int) {
        let date = createDate(weekday: day, hour: hour, minute: minute)
        
        let triggerWeekly = Calendar.current.dateComponents([.weekday,.hour,.minute,.second,], from: date)
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Time to Practice"
            content.body = "An almost fun SAT question is ready for you"
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
            notification.alertBody = "An almost fun SAT question is ready for you"
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
