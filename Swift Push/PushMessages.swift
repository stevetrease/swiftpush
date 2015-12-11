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
            let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let dayReceived = cal.dateFromComponents(cal.components([.Day , .Month, .Year ], fromDate: timeReceived!))
            let dayToday = cal.dateFromComponents(cal.components([.Day , .Month, .Year ], fromDate: NSDate()))
            
            if (dayReceived == dayToday) {
                return "Today"
            } else {
                    return NSDateFormatter.localizedStringFromDate(dayReceived!, dateStyle: .MediumStyle, timeStyle: .NoStyle) as String
            }
        }
    }
}
