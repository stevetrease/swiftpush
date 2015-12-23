//
//  PushMessages+CoreDataProperties.swift
//  Swift Push
//
//  Created by Steve Trease on 23/12/2015.
//  Copyright © 2015 Steve Trease. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PushMessages {

    @NSManaged var alertText: String?
    @NSManaged var isAlert: NSNumber?
    @NSManaged var messageText: String?
    @NSManaged var timeReceived: NSDate?
    @NSManaged var messageID: NSNumber?

}
