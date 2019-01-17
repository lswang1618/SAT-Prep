//
//  AccountViewController.swift
//  SAT Prep
//
//  Created by Lisa Wang on 6/12/18.
//  Copyright © 2018 Lisa Wang. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Photos
import UserNotifications

class AccountViewController: UIViewController {
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var notificationMessage: UILabel!
    
    @IBOutlet weak var dateView: UIStackView!
    @IBOutlet weak var sunday: UIButton!
    @IBOutlet weak var monday: UIButton!
    @IBOutlet weak var tuesday: UIButton!
    @IBOutlet weak var wednesday: UIButton!
    @IBOutlet weak var thursday: UIButton!
    @IBOutlet weak var friday: UIButton!
    @IBOutlet weak var saturday: UIButton!
    
    var notificationsOff: Bool = false
    var profileURL: String = "" 
    var name: String = ""
    var days: Array<Int> = []
    var time: Int = 0
    var uid: String = ""
    var dayLabels: Array<UIButton> = []
    var db: Firestore!
    weak var parentVC: SignInController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentVC = (parent as! SignInController)
        parentVC?.navigationController?.navigationBar.barTintColor = UIColor(red:0.00, green:0.58, blue:0.74, alpha:1.0)
        
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        profileImage.layer.cornerRadius = profileImage.frame.width/2
        profileImage.layer.borderWidth = 4
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.clipsToBounds = true
        profileImage.layer.masksToBounds = true
        dayLabels = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
        
        checkNotificationSetting()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(checkNotificationSetting), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        db = Firestore.firestore()
        let settings = db.settings
        settings.isPersistenceEnabled = true
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        profileImage.layer.cornerRadius = profileImage.frame.width/2
        
        if name != "" {
            userName.text = name
        }
        
        if profileURL != "" {
            DispatchQueue.global(qos: .userInteractive).async {
                self.addProfileImage(url: self.profileURL)
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        
        var setTime = dateFormatter.date(from: "00:00")
        setTime = setTime?.addingTimeInterval(Double(time) * 60.0 * 15.0)
        timePicker.date = setTime!
        
        renderDates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        db.collection("users").document(uid).updateData([
            "days": days,
            "time": time
        ])
        
        if !notificationsOff { scheduleNotifications() }
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
                notificationsOff = false
            } else {
                notificationsOff = true
            }
            toggleView()
        }
        
    }
    
    @IBAction func toggleNotifications(_ sender: UISwitch) {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                })
            } else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    
    func scheduleNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
        
        for day in days {
            scheduleNotification(day: day + 1)
        }
    }
    
    func scheduleNotification(day: Int) {
        let calendar = Calendar.current
        let date = createDate(weekday: day, hour: Int(calendar.component(.hour, from: timePicker.date)), minute: Int(calendar.component(.minute, from: timePicker.date)))
        let triggerWeekly = Calendar.current.dateComponents([.weekday,.hour,.minute,.second,], from: date)
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Time to Practice"
            content.body = "An almost fun SAT question is ready for you"
            content.sound = UNNotificationSound.default()
            
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
        components.weekday = weekday // sunday = 1 ... saturday = 7
        components.weekdayOrdinal = 10
        components.timeZone = .current
        
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components)!
    }
    
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        let calendar = Calendar.current
        let hour = Int(calendar.component(.hour, from: timePicker.date))
        let minutes = Int(calendar.component(.minute, from: timePicker.date))
        time = hour * 4 + (minutes / 15)
    }
    

    func toggleView() {
        DispatchQueue.main.async {
            self.notificationSwitch.isOn = !self.notificationsOff
            self.dateView.isHidden = self.notificationsOff
            self.timePicker.isHidden = self.notificationsOff
            self.dayLabel.isHidden = self.notificationsOff
            self.timeLabel.isHidden = self.notificationsOff
            if self.notificationsOff {
                self.notificationMessage.text = "Turn on notifications to set up daily reminders"
            } else {
                self.notificationMessage.text = "Pick days and a time to receive a reminder"
            }
        }
    }
    
    func renderDates() {
        for day in days {
            let label = dayLabels[day]
            label.layer.masksToBounds = true
            label.layer.cornerRadius = label.frame.width/2
            label.backgroundColor = UIColor.white
        }
    }
    
    func toggleDate(button: UIButton, index: Int) {
        print("bye")
        if button.layer.backgroundColor == UIColor.white.cgColor {
            button.backgroundColor = UIColor.clear
            days.remove(at: days.index(of: index)!)
        } else {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.frame.width/2
            button.backgroundColor = UIColor.white
            days.append(index)
        }
    }
    
    @IBAction func editName(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Name?", message: "Change username:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Done", style: .default) { [unowned self] _ in
            guard let textFields = alertController.textFields,
                textFields.count > 0 else {
                    // Could not find textfield
                    return
            }
            
            let field = textFields[0]
            // store your data
            self.db.collection("users").document(self.uid).updateData([
                "name": field.text!
            ])
            self.userName.text = field.text
            self.name = field.text!
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { [unowned self] textField in
            textField.placeholder = self.name
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func toggleSunday(_ sender: UIButton) {
        toggleDate(button: sunday, index: 0)
    }
    
    @IBAction func toggleMonday(_ sender: UIButton) {
        toggleDate(button: monday, index: 1)
    }
    
    @IBAction func toggleTuesday(_ sender: UIButton) {
        toggleDate(button: tuesday, index: 2)
    }
    
    @IBAction func toggleWednesday(_ sender: UIButton) {
        toggleDate(button: wednesday, index: 3)
    }
    
    @IBAction func toggleThursday(_ sender: UIButton) {
        toggleDate(button: thursday, index: 4)
    }
    
    @IBAction func toggleFriday(_ sender: UIButton) {
        toggleDate(button: friday, index: 5)
    }
    
    @IBAction func toggleSaturday(_ sender: UIButton) {
        toggleDate(button: saturday, index: 6)
    }
    
    func addProfileImage(url: String) {
        do {
            let imageURL = URL(string: url)
            let data = try Data(contentsOf: imageURL!)
            profileImage.setBackgroundImage(UIImage(data: data), for: .normal)
            profileImage.contentMode = .scaleAspectFit
        }
        catch{
            print(error)
        }
    }
    
    @IBAction func editProfileImage(_ sender: UIButton) {
        checkPermission { [unowned self] in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }
    }
}

extension AccountViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func checkPermission(handler: @escaping () -> Void) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            // Access is already granted by user
            handler()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized {
                    // Access is granted by user
                    handler()
                }
            }
        default:
            print("Error: no access to photo album.")
        }
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage

        self.dismiss(animated: true) { [unowned self] in
            self.profileImage.setBackgroundImage(image, for: .normal)
            var data = Data()
            data = UIImageJPEGRepresentation(image!, 0.8)!
            // set upload path
            let filePath = "\("userPhoto")/\(Auth.auth().currentUser!.uid)/"
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let photoRef = storageRef.child(filePath)
            let _ = photoRef.putData(data, metadata: metaData) { metadata, error in
                guard metadata != nil else { return }
                print(storageRef.downloadURL)
                
                photoRef.downloadURL { (url, error) in
                    
                    
                    if error != nil { return }
                    let downloadURL = "\(String(describing: url!))"
                    
                    self.db.collection("users").document(self.uid).updateData([
                        "profileImage": downloadURL
                    ])
                }
            }
        }
    }
}
