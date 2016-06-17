//
//  PushMessages.swift
//  Swift Push
//
//  Created by Steve Trease on 08/12/2015.
//  Copyright © 2015 Steve Trease. All rights reserved.
//

import Foundation
import CoreData


class PushMessages: NSManagedObject {
    // Insert code here to add functionality to your managed object subclass
    
    var sectionCriteria: String {
        get {
            let cal = Calendar(calendarIdentifier: Calendar.Identifier.gregorian)!
            let dayReceived = cal.date(from: cal.components([.day , .month, .year ], from: timeReceived! as Date))

            let dayToday = cal.date(from: cal.components([.day , .month, .year ], from: Date()))
            
            if (dayReceived == dayToday) {
                return "Today"
            } else if (dayReceived == cal.date(byAdding: [.day], value: -1, to: dayToday!, options: [])) {
                return "Yesterday"
            }
            // otherwise just use date for section header
            return DateFormatter.localizedString(from: dayReceived!, dateStyle: .mediumStyle, timeStyle: .noStyle) as String
        }
    }
}
