//
//  MasterViewController.swift
//  Swift Push 4
//
//  Created by Steve Trease on 16/06/2015.
//  Copyright © 2015 Steve Trease. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchResultsUpdating {

    var filteredNotifications = [NotificationData]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        _ = notificationCenter.addObserverForName("dataChanged", object:nil, queue: mainQueue) { _ in
            self.tableView.reloadData()
        }
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = true
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        // Reload the table
        self.tableView.reloadData()
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
        if (self.resultSearchController.active) {
            print("filtered")
            return self.filteredNotifications.count
        }
        else {
            print("unfiltered")
            return notifications.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("cellForRowAtIndexPath ", indexPath.row)
        var notification : NotificationData
        
        notification = notifications[indexPath.row]

        if (self.resultSearchController.active) {
            notification = filteredNotifications[indexPath.row]
        } else {
            notification = notifications[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.layer.masksToBounds = true
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.textLabel?.text = notification.alert as String
        cell.detailTextLabel?.text = NSDateFormatter.localizedStringFromDate(notification.timeStampSent, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as String
            + " (\(notification.messageID))"
        
        return cell
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        print(updateSearchResultsForSearchController)
        print(searchController.searchBar.text!)
        
        // filteredNotifications.removeAll(keepCapacity: false)
        if searchController.searchBar.text! == "" {
            filteredNotifications = notifications
        } else {
            self.filteredNotifications = notifications.filter({( notification: NotificationData) -> Bool in
                // let categoryMatch = (scope == "All") || (notification.alert == scope)
                let stringMatch = notification.alert.rangeOfString(searchController.searchBar.text!)
                return (stringMatch != nil)
            })
        }
        self.tableView.reloadData()
    }
    
}



