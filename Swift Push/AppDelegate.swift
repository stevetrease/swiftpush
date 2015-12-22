//
//  AppDelegate.swift
//  Done
//
//  Created by Bart Jacobs on 19/10/15.
//  Copyright © 2015 Envato Tuts+. All rights reserved.
//

import UIKit
import CoreData

var maximumRecords = 500


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        switch (application.applicationState) {
        case UIApplicationState.Active:
            print ("didFinishLaunchingWithOptions - active")
        case UIApplicationState.Inactive:
            print ("didFinishLaunchingWithOptions - inactive")
        case UIApplicationState.Background:
            print ("didFinishLaunchingWithOptions - background")
        }
        
        let versionNumber: AnyObject? = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"]
        print ("version \(versionNumber!)")
        
        // Fetch Main Storyboard
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate Root Navigation Controller
        let rootNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("StoryboardIDRootNavigationController") as! UINavigationController
        
        // Configure View Controller
        let viewController = rootNavigationController.topViewController as? ViewController
        
        if let viewController = viewController {
            context = self.managedObjectContext
        }
        
        // count records and display in startup message
        let fetch = NSFetchRequest (entityName: "PushMessages")
        do {
            let records = try self.managedObjectContext.executeFetchRequest(fetch)
            newRecord("Swift Push (\(versionNumber!)) starting on " + UIDevice.currentDevice().name + " with \(records.count) of \(maximumRecords) records", alert: true)
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        // newRecord("Test alert", alert: true)
        // newRecord("Test message", alert: false)
 
        // Configure Window
        window?.rootViewController = rootNavigationController
        
        // setup push notifications
        let types: UIUserNotificationType =
        [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        
        let settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
        
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()
        
        return true
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken:NSData) {
        // let existingToken: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken")
        
        print("device token is " + deviceToken.description)
        NSUserDefaults.standardUserDefaults().setObject(deviceToken.description as String, forKey:"deviceToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let receipt = NSBundle.mainBundle().appStoreReceiptURL?.lastPathComponent
        let mode = receipt
        let versionNumber: AnyObject? = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.trease.eu/ibeacon/swiftpush/")!)
        request.HTTPMethod = "POST"
        var bodyData = "token=\(deviceToken.description)"
        bodyData += "&device=\(UIDevice.currentDevice().name)"
        bodyData += "&mode=\(mode!)"
        bodyData += "&version=\(versionNumber!)"
        bodyData += "&type=iOS"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            let x = response as? NSHTTPURLResponse
            print ("status code \(x?.statusCode)")
        }
        task.resume()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error:NSError) {
        print("Failed to register device token")
        print( error.localizedDescription )
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        switch (application.applicationState) {
        case UIApplicationState.Active:
            print ("notification received by AppDeligate whilst active")
        case UIApplicationState.Inactive:
            print ("notification received by AppDeligate whilst inactive")
        case UIApplicationState.Background:
            print ("notification received by AppDeligate whilst in background")
        }
        print (userInfo)
        
        var messageStringFinal: String = ""
        var alertStringFinal: String = ""
        var messageIDFinal: Int = 0
        
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? String {
                alertStringFinal = alert
            }
        }
        
        if let messageID = userInfo["messageID"] as? Int {
            messageIDFinal = messageID
        }
        
        if let message = userInfo["payload"] as? String {
            messageStringFinal = message
        }
        
        let isAlert: Bool
        if alertStringFinal == "" {
            isAlert = false
        } else {
            isAlert = true
        }
        
        newRecord(messageStringFinal, alert: isAlert)
        
        // finished
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    
    

    func applicationWillResignActive(application: UIApplication) {}

    func applicationDidEnterBackground(application: UIApplication) {
        saveManagedObjectContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {}

    func applicationDidBecomeActive(application: UIApplication) {}

    func applicationWillTerminate(application: UIApplication) {
        saveManagedObjectContext()
    }
    
    // MARK: -
    // MARK: Core Data Stack
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Swift_Push", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let persistentStoreCoordinator = self.persistentStoreCoordinator
        
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // URL Documents Directory
        let URLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let applicationDocumentsDirectory = URLs[(URLs.count - 1)]
        
        // URL Persistent Store
        let URLPersistentStore = applicationDocumentsDirectory.URLByAppendingPathComponent("Done.sqlite")
        
        do {
            // Add Persistent Store to Persistent Store Coordinator
            try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: URLPersistentStore, options: nil)
            
        } catch {
            // Populate Error
            var userInfo = [String: AnyObject]()
            userInfo[NSLocalizedDescriptionKey] = "There was an error creating or loading the application's saved data."
            userInfo[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            
            userInfo[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "com.tutsplus.Done", code: 1001, userInfo: userInfo)
            
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            abort()
        }
        
        return persistentStoreCoordinator
    }()
    
    // MARK: -
    // MARK: Helper Methods
    private func saveManagedObjectContext() {
        do {
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
    }

}
