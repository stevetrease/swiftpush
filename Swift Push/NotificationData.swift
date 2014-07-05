//
//  NotificationData.swift
//  Table View
//
//  Created by steve on 03/07/2014.
//  Copyright (c) 2014 Trease. All rights reserved.
//

import Foundation

// A single, global instance of this class
var notifications = NotificationData(item: [])

class NotificationData: NSObject {
    var items: String[]
    
    init (item: String[]) {
        self.items = item
    }
}