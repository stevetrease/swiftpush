//
//  NotificationsTableViewController.swift
//  Swift Push 3
//
//  Created by steve on 06/09/2014.
//  Copyright (c) 2014 steve. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        println("viewDidLoad")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        var observer = notificationCenter.addObserverForName("dataChanged", object:nil, queue: mainQueue) { _ in
            self.tableView.reloadData()
        }
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension

        // self.tableView.layer.cornerRadius = 5.0
        // self.tableView.layer.masksToBounds = true
        
        // self.view.backgroundColor = UIColor(red: 0.95, green: 0, blue: 0, alpha: 1.0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    // Fix suggested at http://www.appcoda.com/self-sizing-cells/
    //
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        // println("numberOfRowsInSection")
        return notifications.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // println("cellForRowAtIndexPath")
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "ReuseCell")!
        
        // cell.layer.cornerRadius = 5.0
        // cell.layer.masksToBounds = true
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        var timeStamp = NSDateFormatter.localizedStringFromDate(notifications[indexPath.row].timeStamp, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        cell.textLabel?.text = notifications[indexPath.row].alert as String
        
        var detailString: String = ""
        // is there a message payload?
        if (notifications[indexPath.row].payload != "" ) {
            detailString =
                notifications[indexPath.row].payload
                + "\n"
        }
        detailString = detailString + timeStamp
        if (notifications[indexPath.row].messageID > 0) {
            detailString = detailString
                + " ("
                + String(notifications[indexPath.row].messageID)
                + ")"
        }
        cell.detailTextLabel?.text = detailString
        
        if (indexPath.row % 2 == 0 ) {
            cell.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        println("selecting row: \(indexPath.row)")
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        notifications.removeAtIndex(indexPath.row)
        println("removing row: ", indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
    }
    
    func onContentSizeChange(notification: NSNotification) {
        tableView.reloadData()
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
