//
//  NotificationData.swift
//  Swift Push 3
//
//  Created by steve on 06/09/2014.
//  Copyright (c) 2014 steve. All rights reserved.
//

import Foundation

// A single, global instance of this class
var notifications = [NotificationData]()
let maxNotifications = 64

class NotificationData {
    var alert: String = ""
    var payload: String = ""
    var receivedAt = NSDate()
    var readYet: Bool = false
}