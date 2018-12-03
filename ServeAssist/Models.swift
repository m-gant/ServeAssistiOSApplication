//
//  Models.swift
//  ServeAssist
//
//  Created by Mitchell  Gant on 12/1/18.
//  Copyright © 2018 mitchell gant. All rights reserved.
//

import UIKit


struct Notification {
    var location: Location
    var type: NotificationType
    var priority: Bool
    var description: String
    
    func detailedDescription() -> String {
        let detailedDescription = location.rawValue + " needs " + type.rawValue + ": " + description
        return detailedDescription
    }
}


enum NotificationType: String {
    case Order, Kitchen, Utility, Drink, Check
}

enum Location: String {
    case Table1 = "Table 1", Table2 = "Table 2", Table3 = "Table 3", Table4 = "Table 4"
}
