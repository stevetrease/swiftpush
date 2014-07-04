//
//  ViewController.swift
//  Table View
//
//  Created by steve on 02/07/2014.
//  Copyright (c) 2014 Trease. All rights reserved.
//

import UIKit

// var tableView: UITableView = UITableView()



class ViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // println("viewDidLoad")
        println(notifications.items.count)
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
        cell.text = notifications.items[indexPath.row] as String
        cell.detailTextLabel.text = notifications.items[indexPath.row] as String
        println("adding row: " + cell.text)
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
