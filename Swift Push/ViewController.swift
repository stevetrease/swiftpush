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


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    let ReuseIdentifierToDoCell = "Cell"
    
    var searchResultsController = UISearchController()
    var searchPredicate: Predicate?
    var fetchedResultsController: NSFetchedResultsController<PushMessages>?
    
    @IBOutlet weak var tableView: UITableView!

    
    // MARK: -
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: allRecordsFetchRequest(""), managedObjectContext: context, sectionNameKeyPath: "sectionCriteria", cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try self.fetchedResultsController!.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        self.navigationController?.navigationBar.barTintColor = UIColor.lightGray()
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.searchResultsController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.autocapitalizationType = .none
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
    }
    
    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController!.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController!.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let sections = fetchedResultsController!.sections {
            let sectionInfo = sections[section]
            return ("\(sectionInfo.numberOfObjects)")
        }
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController!.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifierToDoCell, for: indexPath)
        
        // Configure Table View Cell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        // Fetch Record
        // print ("configureCell \(indexPath)")
        let record = fetchedResultsController!.object(at: indexPath)
        
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.text = record.value(forKey: "messageText") as? String
        // cell.layer.masksToBounds = true
        
        cell.detailTextLabel!.numberOfLines = 0
        cell.detailTextLabel!.text = DateFormatter.localizedString(from: (record.value(forKey: "timeReceived") as? Date)!, dateStyle: .mediumStyle, timeStyle: .shortStyle) as String
        
        if let value = record.value(forKey: "isAlert") {
            if (value as! Bool) {
                cell.backgroundColor = UIColor(red: 245 / 255, green: 245 / 255 , blue: 245 / 255, alpha: 1)
            } else {
                cell.backgroundColor = UIColor.white()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // Fetch Record
            let record = fetchedResultsController!.object(at: indexPath) as NSManagedObject
            
            // Delete Record
            context.delete(record)
        }
    }
    
    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: -
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // let tableView = controller == fetchedResultsController ? self.tableView : searchDisplayController?.searchResultsTableView
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print ("didChangeSection")
        switch type {
        case .insert:
            let sectionIndexSet = IndexSet(integer: sectionIndex)
            self.tableView.insertSections(sectionIndexSet, with: UITableViewRowAnimation.fade)
        case .delete:
            let sectionIndexSet = IndexSet(integer: sectionIndex)
            self.tableView.deleteSections(sectionIndexSet, with: UITableViewRowAnimation.fade)
        default:
            print ("default")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print ("didChangeObject")
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath)
                configureCell(cell!, atIndexPath: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
    
        
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchText = searchController.searchBar.text!
        print("updateSearchResultsForSearchController: \(searchText.characters.count) \(searchText)")
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: allRecordsFetchRequest(searchText), managedObjectContext: context, sectionNameKeyPath: "sectionCriteria", cacheName: nil)
        do {
            try self.fetchedResultsController!.performFetch()
            self.tableView.reloadData()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
}






func newRecord (_ messageText: String, alert: Bool,  messageID: Int) {
    let entity = NSEntityDescription.entity(forEntityName: "PushMessages", in: context)
    
    // Initialize Record
    let record = NSManagedObject(entity: entity!, insertInto: context)
    
    // Populate Record
    record.setValue(messageText, forKey: "messageText")
    record.setValue(Date(), forKey: "timeReceived")
    record.setValue(alert, forKey: "isAlert")
    record.setValue(messageID, forKey: "messageID")
    
    // check we don't have too many records
    let fetch: NSFetchRequest<PushMessages> = PushMessages.fetchRequest()
    // let fetch = NSFetchRequest (entityName: "PushMessages")
    do {
        let records = try context.fetch(fetch)
        if records.count > maximumRecords {
            // if we have too many reorcrds, delete them down to MaximumRecords
            print ("too many records (\(records.count) of \(maximumRecords))")
            
            let deleteFetchRequest: NSFetchRequest<PushMessages> = PushMessages.fetchRequest()
            //let deleteFetchRequest = NSFetchRequest(entityName: "PushMessages")
            deleteFetchRequest.fetchLimit = records.count - maximumRecords

            let sortDescriptor = SortDescriptor(key: "timeReceived", ascending: true)
            deleteFetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let deleteFetchResults = try context.fetch (deleteFetchRequest)
                for var delRecord in deleteFetchResults {
                    context.delete(delRecord as NSManagedObject)
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


func allRecordsFetchRequest(_ searchText: String) -> NSFetchRequest<PushMessages> {
    print ("allRecordsFetchRequest \(searchText)")
    let fetchRequest: NSFetchRequest<PushMessages> = PushMessages.fetchRequest()
    // let fetchRequest = NSFetchRequest(entityName: "PushMessages")
    
    fetchRequest.fetchBatchSize = 100
    let sortDescriptor = SortDescriptor(key: "timeReceived", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    if (searchText.characters.count != 0) {
        fetchRequest.predicate = Predicate(format: "messageText contains[c] %@", searchText)
    } else {
        fetchRequest.predicate = nil
    }
    
    do {
        let records = try context.fetch(fetchRequest)
        print (records.count)
    } catch {
        let fetchError = error as NSError
        print("\(fetchError), \(fetchError.userInfo)")
    }
    
    return fetchRequest
}
