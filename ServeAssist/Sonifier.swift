//
//  Sonifier.swift
//  ServeAssist
//
//  Created by Mitchell  Gant on 12/2/18.
//  Copyright © 2018 mitchell gant. All rights reserved.
//

import UIKit
import AVFoundation

class Sonifier: NSObject, AVAudioPlayerDelegate {
    
    
    private static var queuedPlayers: [AVPlayer] = []
    private static var soundPlaying = false
    
    
    static func sonifyAggregateByType(type: NotificationType, notifications: [Notification] ) {
        guard notifications.count > 0 else {
            return
        }
        var speech =  ""
        var tables : [Location] = []
        for notification in notifications {
            if !tables.contains(notification.location) {
                tables.append(notification.location)
            }
        }
        
        
        if tables.count == 1 {
            speech += tables[0].rawValue + " needs"
        } else {
            for index in 0..<tables.count {
                if index == (tables.count - 1) {
                    speech += " and " + tables[index].rawValue + " need"
                } else {
                    speech += tables[index].rawValue
                }
            }
        }
        
        
        
        switch type {
        case .Check:
            speech += " the check. "
            break
        case .Drink:
            speech += " drinks."
            break
        case .Kitchen:
            speech += " food from the kitchen."
            break
        case .Order:
            speech += " to  order."
            break
        case .Utility:
            speech += " utilities."
            break
        }
        
        let utterance = AVSpeechUtterance(string: speech)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    static func sonifyAggregate(notifications: [Notification]) {
        var typeCounts : [NotificationType: Int] = [:]
        
        for notification in notifications {
            if let curCount = typeCounts[notification.type] {
                typeCounts[notification.type] = curCount + 1
            } else {
                typeCounts[notification.type] = 1
            }
        }
        
        var speech = "You have "
        
        for type in typeCounts.keys {
            let curCount = typeCounts[type] ?? 0
            speech += String(curCount) + " "
            if curCount > 1 {
                
                switch type {
                case .Order:
                    speech += "orders"
                    break
                case .Kitchen:
                    speech += "items in the kitchen"
                    break
                case .Check:
                    speech += "checks"
                    break
                case .Drink:
                    speech += "drinks"
                    break
                case .Utility:
                    speech += "utilities"
                    break
                }
                
            } else {
                
                switch type {
                case .Order:
                    speech += "order"
                    break
                case .Kitchen:
                    speech += "item in the kitchen"
                    break
                case .Check:
                    speech += "check"
                    break
                case .Drink:
                    speech += "drink"
                    break
                case .Utility:
                    speech += "utility"
                    break
                }
                
            }
            
        }
        
        let utterance = AVSpeechUtterance(string: speech)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
    }
    
    static func sonifyAggregateByTable(location: Location, notifications: [Notification]) {
        guard notifications.count > 0 else {
            return
        }
        
        var speech = location.rawValue + " needs"
        
        var types: [NotificationType] = []
        for notification in notifications{
            if (!types.contains(notification.type)) {
                types.append(notification.type)
            }
        }
        
        for index in 0..<types.count {
            if index == types.count - 1 && index != 0 {
                speech += " and"
            }
            var type = types[index]
            
            switch type {
            case .Check:
                speech += " the check "
                break
            case .Drink:
                speech += " drinks"
                break
            case .Kitchen:
                speech += " food from the kitchen"
                break
            case .Order:
                speech += " to  order"
                break
            case .Utility:
                speech += " utilities"
                break
            }
            
        }
        
        let utterance = AVSpeechUtterance(string: speech)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
    }
    
    func sonify(notification: Notification, completion: @escaping (()-> ())) {
    
        var tableSoundFilename = ""
        switch notification.location {
        case .Table1:
            tableSoundFilename = "Table1.wav"
            break
        case .Table2:
            tableSoundFilename = "Table2.wav"
        case .Table3:
            tableSoundFilename = "Table3.wav"
            break
        case .Table4:
            tableSoundFilename = "Table4.wav"
            break
        }
        
        var typeSoundFilename = ""
        switch notification.type {
        case .Check:
            typeSoundFilename = "cash_1.wav"
            break
        case .Drink:
            typeSoundFilename = "water_splash_1.wav"
            break
        case .Kitchen:
            typeSoundFilename = "bell.wav"
            break
        case .Order:
            typeSoundFilename = "cs_2.wav"
            break
        case .Utility:
            typeSoundFilename = "clearingthroat.wav"
            break
        }
        
        
        
        let tableURL = Bundle.main.url(forResource: tableSoundFilename, withExtension: nil)!
//        let tablePlayerItem = AVPlayerItem(url: tableURL)
//        print(soundPlaying)
        let tablePlayerItem = AVPlayerItem(url: tableURL)
        addToQueue(playerItem: tablePlayerItem)
        
        
        let typePath = Bundle.main.path(forResource: typeSoundFilename, ofType: nil)!
        let typeURL = URL(fileURLWithPath: typePath)
        let typePlayerItem = AVPlayerItem(url: typeURL)
        addToQueue(playerItem: typePlayerItem)
//        if let typePlayer = try? AVAudioPlayer(contentsOf: typeURL) {
//            addToQueue(player: typePlayer)
//        }
        
        
        completion()
    }
    
    func addToQueue(playerItem: AVPlayerItem) {
       
        var player = AVPlayer(playerItem: playerItem)
        //player.delegate = self
        Sonifier.queuedPlayers.append(player)
        //print(Sonifier.soundPlaying)
        if !Sonifier.soundPlaying {
            Sonifier.playQueuedPlayer()
        }
    }
    
    
    
    static func playQueuedPlayer() {
        if queuedPlayers.count > 0 {
            ViewController.globalPlayer = queuedPlayers.remove(at: 0)
            let playerItem = ViewController.globalPlayer.currentItem!
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            ViewController.globalPlayer.play()
            soundPlaying = true
            print(queuedPlayers.count)
        } else {
            soundPlaying = false
        }
        print(soundPlaying)
    }
    
    @objc static func playerDidFinishPlaying() {
        playQueuedPlayer()
        print("loop")
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Sonifier.playQueuedPlayer()
    }
}
