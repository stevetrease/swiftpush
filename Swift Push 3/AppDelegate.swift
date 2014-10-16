//
//  AppDelegate.swift
//  Swift Push 3
//
//  Created by steve on 06/09/2014.
//  Copyright (c) 2014 steve. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // var versionNumber: AnyObject = NSBundle.mainBundle().infoDictionary["CFBundleVersion"]
        // println ("version \(versionNumber)")
        
        var item = NotificationData()
        // item.alert = "Swift Push (\(versionNumber)) starting on " + UIDevice.currentDevice().name
        item.alert = "Swift Push starting on " + UIDevice.currentDevice().name
        
        item.readYet = false
        notifications.insert(item, atIndex: 0)
        
        switch (application.applicationState) {
        case UIApplicationState.Active:
            println ("didFinishLaunchingWithOptions - active")
        case UIApplicationState.Inactive:
            println ("didFinishLaunchingWithOptions - inactive")
        case UIApplicationState.Background:
            println ("didFinishLaunchingWithOptions - background")
        default:
            println ("didFinishLaunchingWithOptions - unknown application state")
        }
        
        var types: UIUserNotificationType = UIUserNotificationType.Badge |
            UIUserNotificationType.Alert |
            UIUserNotificationType.Sound
        
        var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
        
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()
        
        // screenshot notification
        let mainQueue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationUserDidTakeScreenshotNotification, object: nil, queue: mainQueue) { notification in
            println("screenshot taken")
        }
        
        return true
    }
    
    
    func application(application: UIApplication!, didRegisterForRemoteNotificationsWithDeviceToken deviceToken:NSData!) {
        
        let existingToken: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken")
        
        println("device token is " + deviceToken.description)
        NSUserDefaults.standardUserDefaults().setObject(deviceToken.description as String, forKey:"deviceToken")
        NSUserDefaults.standardUserDefaults().synchronize()
            
        // register device token with push service
        var request = NSMutableURLRequest(URL: NSURL(string: "https://www.trease.eu/ibeacon/")!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var bodyData = "token=" + deviceToken.description
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        var connection = NSURLConnection(request: request, delegate: self, startImmediately: false)
        connection?.start()
    }
    
    
    func application(application: UIApplication!, didFailToRegisterForRemoteNotificationsWithError error:NSError!) {
        println("Failed to register device token")
        println( error.localizedDescription )
    }
    
    
    func application(application: UIApplication!, didReceiveRemoteNotification userInfo:NSDictionary!, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)!) {
        println ("Push message received by AppDeligate: \(userInfo)")
        
        var t1: AnyObject! = userInfo.objectForKey("aps")
        
        var alert = t1.objectForKey("alert") as String
        var payload = userInfo.objectForKey("payload") as String
        
        var item = NotificationData()
        item.alert = alert
        item.payload = payload
        item.readYet = false
        
        notifications.insert(item, atIndex: 0)
        if (notifications.count > maxNotifications) {
            notifications.removeLast()
        }
        
        // notify tableview to refresh
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName("dataChanged", object: self)
        
        switch (application.applicationState) {
        case UIApplicationState.Active:
            println ("notification received whilst active")
        case UIApplicationState.Inactive:
            println ("notification received whilst inactive")
        case UIApplicationState.Background:
            println ("notification received whilst in background")
        default:
            println("notification received with unknown application state")
        }
        completionHandler(UIBackgroundFetchResult.NewData)
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Trease.Swift_Push_3" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Swift_Push_3", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Swift_Push_3.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            // error = NSError.errorWithDomain("YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

