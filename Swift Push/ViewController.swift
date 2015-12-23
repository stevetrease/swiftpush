//
//  ViewController.swift
//  Done
//
//  Created by Bart Jacobs on 19/10/15.
//  Copyright © 2015 Envato Tuts+. All rights reserved.
//

import UIKit
import CoreData

var context: NSManagedObjectContext!


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    let ReuseIdentifierToDoCell = "Cell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var alertSwitch: UISwitch!

    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "PushMessages")
        fetchRequest.fetchBatchSize = 100
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "timeReceived", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "sectionCriteria", cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: -
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        
        // let bounds = self.navigationController?.navigationBar.bounds as CGRect!
        // let visualEffectView = UIVisualEffectView (effect: UIBlurEffect (style: .Light)) as UIVisualEffectView
        // visualEffectView.frame = bounds
        // visualEffectView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        // self.navigationController?.navigationBar.addSubview(visualEffectView)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.lightGrayColor()
        self.navigationController?.navigationBar.translucent = true
    
        
    }
    
    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierToDoCell, forIndexPath: indexPath)
        
        // Configure Table View Cell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Record
        let record = fetchedResultsController.objectAtIndexPath(indexPath)
        
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.text = record.valueForKey("messageText") as? String
        // cell.layer.masksToBounds = true
        
        cell.detailTextLabel!.numberOfLines = 0
        cell.detailTextLabel!.text = NSDateFormatter.localizedStringFromDate((record.valueForKey("timeReceived") as? NSDate)!, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as String
        
        if let value = record.valueForKey("isAlert") {
            if (value as! Bool) {
                cell.backgroundColor = UIColor(red: 245 / 255, green: 245 / 255 , blue: 245 / 255, alpha: 1)
            } else {
                cell.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            // Fetch Record
            let record = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            
            // Delete Record
            context.deleteObject(record)
        }
    }
    
    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: -
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        print ("didChangeSection")
        switch type {
        case .Insert:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.tableView.insertSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.tableView.deleteSections(sectionIndexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            ""
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        print ("didChangeObject")
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                configureCell(cell!, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
    
    
    @IBAction func alertSwitch(sender: AnyObject) {
        print("alert switch state is \(alertSwitch.on)")
    }
}



func newRecord (messageText: String, alert: Bool,  messageID: Int) {
    let entity = NSEntityDescription.entityForName("PushMessages", inManagedObjectContext: context)
    
    // Initialize Record
    let record = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
    
    // Populate Record
    record.setValue(messageText, forKey: "messageText")
    record.setValue(NSDate(), forKey: "timeReceived")
    record.setValue(alert, forKey: "isAlert")
    record.setValue(messageID, forKey: "messageID")
    
    // check we don't have too many records
    let fetch = NSFetchRequest (entityName: "PushMessages")
    do {
        let records = try context.executeFetchRequest(fetch)
        if records.count > maximumRecords {
            // if we have too many reorcrds, delete them down to MaximumRecords
            print ("too many records (\(records.count) of \(maximumRecords))")
            
            let deleteFetchRequest = NSFetchRequest(entityName: "PushMessages")
            deleteFetchRequest.fetchLimit = records.count - maximumRecords

            let sortDescriptor = NSSortDescriptor(key: "timeReceived", ascending: true)
            deleteFetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let deleteFetchResults = try context.executeFetchRequest (deleteFetchRequest)

                    for var delRecord in deleteFetchResults {
                    context.deleteObject(delRecord as! NSManagedObject)
                }
            } catch {
                let fetchError = error as NSError
                print("\(fetchError), \(fetchError.userInfo)")
            }
        }
    } catch {
        let fetchError = error as NSError
        print("\(fetchError), \(fetchError.userInfo)")
    }
    
    // save the changed table
    do {
        try record.managedObjectContext?.save()
    } catch {
        let saveError = error as NSError
        print("\(saveError), \(saveError.userInfo)")
    }
}