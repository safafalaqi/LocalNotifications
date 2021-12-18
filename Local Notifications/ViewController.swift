//
//  ViewController.swift
//  Local Notifications
//
//  Created by Safa Falaqi on 14/12/2021.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var startBT: UIButton!
   
    @IBOutlet weak var totalTimeLabel: UILabel!
    var totalTime:Double = 0
    
    @IBOutlet weak var currentTimerLabel: UILabel!
    
    @IBOutlet weak var timeSetLabel: UILabel! //and also the logs
    var logs = ""
    var logIsHidden = true
    
    @IBOutlet weak var timePicker: UIPickerView!
    
    @IBOutlet weak var localNotification: UILabel!
    
    var center:UNUserNotificationCenter?
    
    var startTime:Int?
    var endTime:Int?
    var isActive = false
    var seconds:Double = 0
    var timerCount:Timer?
    
    var pickerData = [
        "1 Minute",  //for testing purpose
        "5 Minutes",
        "10 Minutes",
        "20 Minutes",
        "30 Minutes"]
    
    var selectedTimer = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timePicker.dataSource = self
        timePicker.delegate = self
        

        //request permission for local notification
        center = UNUserNotificationCenter.current()
        center!.requestAuthorization(options: [.alert,.sound])
        {
            (granted,error ) in
        }
        
        startBT.layer.cornerRadius = 10
        
       
    }
    
    //set notification function
    //I have confirmed the UNUserNotificationCenterDelegate to App delegate and implmented userNotificationCenter to show notification on forground
    func createNotification(timer: String,timeInSec: Double ){
        //create the notification content
         let content = UNMutableNotificationContent()
         content.title = "Done!"
         content.body = "your \(timer) is done!"
        content.sound = UNNotificationSound.default
        
         //create the notification trigger
         let date  = Date().addingTimeInterval(timeInSec)
        let dateComponenets = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponenets , repeats: false)
         
         //request
        let identifier = "UYLLocalNotification"
         let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
         
         //register the request
         center!.add(request) {(error) in
             
         }
    }
    

    @IBAction func startTimer(_ sender: UIButton) {
        isActive = true
        //get selected time
        selectedTimer = pickerData[timePicker.selectedRow(inComponent:0)]
        print(selectedTimer)
        var timeInSec:Double = 0
        var t = 0
        switch selectedTimer {
        case "1 Minute": timeInSec = 1 * 60
            totalTime += 1
            t = 1
        case "5 Minutes": timeInSec = 5 * 60
            totalTime += 5
            t = 5
        case "10 Minutes": timeInSec = 10 * 60
            totalTime += 10
            t = 10
        case "20 Minutes": timeInSec = 20 * 60
            totalTime += 20
            t = 20
        default : timeInSec = 30 * 60
            totalTime += 30
            t = 30
        }
        //create local notification with selected time
        createNotification(timer: selectedTimer,timeInSec: timeInSec)
        
        seconds = timeInSec
        timerFinishHandler()
        
        //set labels and add to logs
        totalTimeLabel.text = "Total time: \(Int(totalTime))"
        currentTimerLabel.text = "0 hours, \(t) min"
        timeSetLabel.text = "\(t) minute timer set"
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "hh:mm:ss a"
     
        localNotification.text = "Work until: \(dateFormat.string(from: Date(timeIntervalSinceNow:(Double(t) * 60.0))))"

        logs = logs + "\n\( dateFormat.string(from: Date())) - \( dateFormat.string(from: Date(timeIntervalSinceNow:(Double(t) * 60.0)))) \(selectedTimer) "
        
        
    }
    func timerFinishHandler(){
        
        timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.seconds -= 1
            if self.seconds == 0 {
           
                self.logs = self.logs + " Finished"
                self.currentTimerLabel.text = " "
                self.timeSetLabel.text = self.selectedTimer + " is Finished"
                self.localNotification.text = " "
                self.isActive = false
                timer.invalidate()
            } else {
                print(self.seconds)
            }
        }
    }
    
    @IBAction func cancelTimer(_ sender: UIBarButtonItem) {
        

        //check notification if scheduled and active that means we can cancel it if not dont display alert request
        if isActive {

                    let alert = UIAlertController(title: "", message: "Cancel Current timer?", preferredStyle: UIAlertController.Style.alert)

                    
                    alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.default, handler: nil))
                    
                    // add an action (button) and handler
                 alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (actionSheetController) -> Void in
                     self.logs = self.logs + "\n ABOVE TIMER HAS BEEN CANCELED "
                     self.timeSetLabel.text = "\(self.selectedTimer) timer is Cancelled"
                     //cancel the notification
                     self.center!.removePendingNotificationRequests(withIdentifiers: ["UYLLocalNotification"])
                     //reset the local notification message
                     self.localNotification.text = ""
                     //adjust total time in case if cancel before time is finished
                     self.totalTime -= self.seconds/60
                     self.totalTimeLabel.text = "Total Time: \(Int(self.totalTime))"
                     self.timerCount?.invalidate()
                     self.isActive = false
                     
                     
                 }))
                    
                      // show the alert
                      self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func displayLogs(_ sender: UIBarButtonItem) {
        if logIsHidden == true {
           logIsHidden = false
           timePicker.isHidden = true
           startBT.isHidden = true
            timeSetLabel.text = logs
            localNotification.isHidden = true
        }else{
            logIsHidden = true
            timePicker.isHidden = false
            startBT.isHidden = false
            localNotification.isHidden = false
            if !selectedTimer.isEmpty && isActive{
                timeSetLabel.text = "\(selectedTimer) is set"}
        }
        
    }
    
    //I am assuming that new day means we will sart a new day with a new logs
    @IBAction func newDay(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "", message: "Are you sure it's a new day??", preferredStyle: UIAlertController.Style.alert)

        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // add an action (button) and handler
     alert.addAction(UIAlertAction(title: "New Day", style: UIAlertAction.Style.default, handler: { (actionSheetController) -> Void in
    
         //first clear the logs
         self.logs = ""
         //and reset all the labels
         self.totalTimeLabel.text = "Total Time: 0"
         self.currentTimerLabel.text = " "
         self.timeSetLabel.text = " "
         self.localNotification.text = " "
         self.totalTime = 0
         //cancel counter
         self.timerCount?.invalidate()
         //cancel the notification if exists
         self.center!.removePendingNotificationRequests(withIdentifiers: ["UYLLocalNotification"])
     }))
        
          // show the alert
          self.present(alert, animated: true, completion: nil)
    
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //to specify the size
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    //to set the array to view picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    //to set the color of text to white in view picker
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: pickerData[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }
  
}

