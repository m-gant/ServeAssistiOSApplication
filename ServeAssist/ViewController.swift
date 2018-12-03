//
//  ViewController.swift
//  ServeAssist
//
//  Created by Mitchell  Gant on 12/1/18.
//  Copyright © 2018 mitchell gant. All rights reserved.
//

import UIKit
import AVFoundation
import NotificationCenter

class ViewController: UIViewController {

    
    @IBOutlet weak var tableSegmentControl: UISegmentedControl!
    @IBOutlet weak var typeSegmentControl: UISegmentedControl!
    @IBOutlet weak var prioritySegmentControl: UISegmentedControl!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var notificationTableView: UITableView!
    
    var curTable: Location = .Table1
    var curType: NotificationType = .Order
    var curPriority: Bool = false
    var notifications: [Notification] = []
    var filteredNotifications: [Notification] = []
    var filtered = false
    var filterType : FilteringType = .None
    static var globalPlayer : AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        submitButton.layer.cornerRadius = submitButton.frame.height / 2
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            let table1URL = Bundle.main.url(forResource: "Table1", withExtension: "wav")!
            let playerItem = AVPlayerItem(url: table1URL)
            NotificationCenter.default.addObserver(self, selector: #selector(didFinish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            ViewController.globalPlayer = AVPlayer(playerItem: playerItem)
            ViewController.globalPlayer.play()
        } catch {
            
        }
        
        
    }
    
    @objc func didFinish() {
        print("did Finish")
    }
    
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        switch sender.tag {
        case 0:
            //Table change
            switch sender.selectedSegmentIndex {
            case 0:
                curTable = .Table1
                break
            case 1:
                curTable = .Table2
                break
            case 2:
                curTable = .Table3
                break
            case 3: curTable = .Table4
                break
            default:
                break
            }
            break
        case 1:
            //Type change
            switch sender.selectedSegmentIndex {
            case 0:
                curType = .Order
                break
            case 1:
                curType = .Drink
                break
            case 2:
                curType = .Check
                break
            case 3:
                curType = .Kitchen
                break
            case 4:
                curType = .Utility
                break
            default:
                break
            }
            break
        case 2:
            //Priority change
            curPriority = sender.selectedSegmentIndex != 0
            break
            
        default:
            break
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        let description = descriptionTextField.text ?? ""
        let notification = Notification(location: curTable, type: curType, priority: curPriority, description: description)
        notifications.append(notification)
        notificationTableView.reloadData()
        descriptionTextField.text = ""
    }
    
    
    @IBAction func filterSegmentControlChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            filterType = .Table
            filtered = true
            filteredNotifications = notifications.filter({ (notification) -> Bool in
                return notification.location == .Table1
            })
            break
        case 1:
            filterType = .Table
            filtered = true
            filteredNotifications = notifications.filter({ (notification) -> Bool in
                return notification.location == .Table2
            })
            break
        case 2:
            filterType = .Table
            filtered = true
            filteredNotifications = notifications.filter({ (notification) -> Bool in
                return notification.location == .Table3
            })
            break
        case 3:
            filterType = .Table
            filtered = true
            filteredNotifications = notifications.filter { (notification) -> Bool in
                return notification.location == .Table4
            }
            break
        case 4:
            filterType = .NotifType
            filtered = true
            filteredNotifications = notifications.filter { (notification) -> Bool in
                return notification.type == .Order
            }
            break
        case 5:
            filterType = .NotifType
            filtered = true
            filteredNotifications = notifications.filter({ (notification) -> Bool in
                return notification.type == .Drink
            })
            break
        case 6:
            filterType = .NotifType
            filtered = true
            filteredNotifications = notifications.filter({ (notification) -> Bool in
                return notification.type == .Check
            })
            break
        case 7:
            filterType = .NotifType
            filtered = true
            filteredNotifications = notifications.filter({ (notification) -> Bool in
                return notification.type == .Kitchen
            })
            break
        case 8:
            filterType = .NotifType
            filtered = true
            filteredNotifications = notifications.filter({ (notification) -> Bool in
                return notification.type == .Utility
            })
            break
        case 9:
            filterType = .None
            filtered = false
            break
        default:
            break
        }
        
        notificationTableView.reloadData()
    }
    
    @IBAction func playNotificationsButtonPressed(_ sender: Any) {
        let sonifier = Sonifier()
        let alert = UIAlertController(title: "Choose presentation style", message: nil, preferredStyle: .actionSheet)
        let aggregateAction = UIAlertAction(title: "Aggregate", style: .default) { (_) in
            if self.filtered  && self.filteredNotifications.count > 0 {
                if self.filterType == .Table {
                    Sonifier.sonifyAggregateByTable(location: self.filteredNotifications.first!.location, notifications: self.filteredNotifications)
                } else {
                    Sonifier.sonifyAggregateByType(type: self.filteredNotifications.first!.type, notifications: self.filteredNotifications)
                }
            
            } else if !self.filtered && self.notifications.count > 0 {
                //nothing yet
                Sonifier.sonifyAggregate(notifications: self.notifications)
            }
        }
        
        let sequentialAction = UIAlertAction(title: "Sequential", style: .default) { (_) in
            if self.filtered && self.filteredNotifications.count > 0 {
                for notification in self.filteredNotifications {
                    sonifier.sonify(notification: notification, completion: {
                        //do nothing
                    })
                }
            } else if !self.filtered && self.notifications.count > 0 {
                for notification in self.notifications {
                    sonifier.sonify(notification: notification) {
                        //do nothing
                    }
                }
            }
        }
        
        alert.addAction(aggregateAction)
        alert.addAction(sequentialAction)
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filtered {
            return filteredNotifications.count
        }
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = UITableViewCell()
        var notification: Notification!
        if filtered {
            notification = filteredNotifications[indexPath.row]
        } else {
            notification = notifications[indexPath.row]
        }
        cell.textLabel?.text = notification.detailedDescription()
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && !filtered {
            notifications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    enum FilteringType {
        case Table, NotifType, None
    }
    
    
}

