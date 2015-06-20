//
//  MasterViewController.swift
//  Swift Push 4
//
//  Created by Steve Trease on 16/06/2015.
//  Copyright © 2015 Steve Trease. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        _ = notificationCenter.addObserverForName("dataChanged", object:nil, queue: mainQueue) { _ in
            self.tableView.reloadData()
        }
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("didReceiveMemoryWarning")

    }


    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("cellForRowAtIndexPath ", indexPath.row)
        var notification : NotificationData
        
        notification = notifications[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.layer.masksToBounds = true
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.textLabel?.text = notification.alert as String
        cell.detailTextLabel?.text = NSDateFormatter.localizedStringFromDate(notification.timeStampSent, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as String
            + " (\(notification.messageID))"
        
        return cell
    }
}



