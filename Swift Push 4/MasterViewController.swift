//
//  MasterViewController.swift
//  Swift Push 4
//
//  Created by Steve Trease on 16/06/2015.
//  Copyright © 2015 Steve Trease. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet weak var countLabel: UILabel!

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
            controller.dimsBackgroundDuringPresentation = false
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
            if ((self.filteredNotifications.count == 0) || (notifications.count == self.filteredNotifications.count)) {
                countLabel.hidden = true
            } else {
                countLabel.hidden = false
                countLabel.text = "\(self.filteredNotifications.count) of \(notifications.count)"
            }
            return self.filteredNotifications.count
        }
        else {
            print("unfiltered")
            countLabel.hidden = true
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
        
        cell.textLabel?.text = notification.message as String
        cell.detailTextLabel?.text = NSDateFormatter.localizedStringFromDate(notification.timeStampSent, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as String
            
        if (notification.messageID != 0) {
            cell.detailTextLabel!.text = cell.detailTextLabel!.text! + " (\(notification.messageID))"
        }
        
        // highlight alert messages in lightgray.
        if notification.alert == "" {
            cell.backgroundColor = UIColor.whiteColor()
        } else {
            cell.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
        }

        /*
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = cell.backgroundColor!.colorWithAlphaComponent(0.10)
        } else{
            cell.backgroundColor = cell.backgroundColor!.colorWithAlphaComponent(0.20)
        }
        */
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        print ("canEditRowAtIndexPath")
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print ("commitEditingStyle")
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            notifications.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
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
                let stringMatch = notification.message.rangeOfString(searchController.searchBar.text!, options: .CaseInsensitiveSearch)
                return (stringMatch != nil)
            })
        }
        self.tableView.reloadData()
    }
    
}



