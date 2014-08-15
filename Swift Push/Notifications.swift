//
//  Notifications.swift
//  Swift Push
//
//  Created by steve on 13/08/2014.
//  Copyright (c) 2014 Trease. All rights reserved.
//

import Foundation
import CoreData

class Notifications: NSManagedObject {

    @NSManaged var alert: String
    @NSManaged var payload: String

}
