//
//  NotificationData.swift
//  Swift Push 4
//
//  Copyright (c) 2015 steve. All rights reserved.
//

import Foundation

// A single, global instance of this class
var notifications = [NotificationData]()
let maxNotifications = 128

class NotificationData {
    var alert: String = ""
    // var payload: String = ""
    var timeStampSent = NSDate()
    var timeStampReceived = NSDate()
    var messageID: Int = 0
}