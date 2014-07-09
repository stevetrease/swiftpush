//
//  ViewController.swift
//  Table View
//
//  Created by steve on 02/07/2014.
//  Copyright (c) 2014 Trease. All rights reserved.
//

import UIKit


class ViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // println("viewDidLoad")
        println("viewDidLoad")
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        var observer = notificationCenter.addObserverForName("dataChanged",object:nil, queue: mainQueue) { _ in
           self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return notifications.items.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "dd MMM YYYY HH:MM:SS"
        var dateString = formatter.stringFromDate(NSDate())
        
        cell.textLabel.text = notifications.items[indexPath.row] as String
        cell.detailTextLabel.text = dateString + ": " + notifications.items[indexPath.row] as String
        
        println("adding row: " + cell.textLabel.text)
        return cell
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        println("selecting row: \(indexPath.row)")
    }
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!)
    {
        notifications.items.removeAtIndex(indexPath.row)
        println("removing row: ", indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
    }
    
}
