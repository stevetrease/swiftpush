//
//  AppDelegate.swift
//  Done
//
//  Created by Bart Jacobs on 19/10/15.
//  Copyright © 2015 Envato Tuts+. All rights reserved.
//

import UIKit
import CoreData

let maximumRecords = 1000


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        switch (application.applicationState) {
        case UIApplicationState.active:
            print ("didFinishLaunchingWithOptions - active")
        case UIApplicationState.inactive:
            print ("didFinishLaunchingWithOptions - inactive")
        case UIApplicationState.background:
            print ("didFinishLaunchingWithOptions - background")
        }
        
        let versionNumber: AnyObject? = Bundle.main().infoDictionary?["CFBundleVersion"]
        print ("version \(versionNumber!)")
        
        // Fetch Main Storyboard
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate Root Navigation Controller
        let rootNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "StoryboardIDRootNavigationController") as! UINavigationController
        
        // Configure View Controller
        let viewController = rootNavigationController.topViewController as? ViewController
        
        if let viewController = viewController {
            context = self.managedObjectContext
        }
        
        // count records and display in startup message
        let fetch: NSFetchRequest<PushMessages> = PushMessages.fetchRequest()
        // let fetch = NSFetchRequest (entityName: "PushMessages")
        do {
            let records = try self.managedObjectContext.fetch(fetch)
            newRecord("Swift Push (\(versionNumber!)) starting on " + UIDevice.current().name + " with \(records.count) of \(maximumRecords) records", alert: true, messageID: 0)
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        // newRecord("Test alert", alert: true)
        // newRecord("Test message", alert: false)
 
        // Configure Window
        window?.rootViewController = rootNavigationController

        // register for notifications
        let types: UIUserNotificationType =
            [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let settings: UIUserNotificationSettings = UIUserNotificationSettings( types: types, categories: nil )
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()
        
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken:Data) {
        var token: String = deviceToken.description
        token = token.replacingOccurrences(of: "[^0-9 ]", with: "")
        
        print("device token is \(token)")
        UserDefaults.standard().set(token as String, forKey:"deviceToken")
        UserDefaults.standard().synchronize()
        
        newRecord("Device token is \(token)", alert: false, messageID: 0)
        
        let receipt = Bundle.main().appStoreReceiptURL?.lastPathComponent
        let mode = receipt
        let versionNumber: AnyObject? = Bundle.main().infoDictionary?["CFBundleVersion"]
        
        var request = URLRequest(url: URL(string: "https://www.trease.eu/ibeacon/swiftpush/")!)
        request.httpMethod = "POST"
        var bodyData = "token=\(token)"
        bodyData += "&device=\(UIDevice.current().name)"
        bodyData += "&mode=\(mode!)"
        bodyData += "&version=\(versionNumber!)"
        bodyData += "&type=iOS"
        request.httpBody = bodyData.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared().dataTask(with: request as URLRequest) {
            data, response, error in
            let x = response as? HTTPURLResponse
            print ("status code \(x?.statusCode)")
        }
        task.resume()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error:NSError) {
        print("Failed to register device token")
        print( error.localizedDescription )
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        switch (application.applicationState) {
        case UIApplicationState.active:
            print ("notification received by AppDeligate whilst active")
        case UIApplicationState.inactive:
            print ("notification received by AppDeligate whilst inactive")
        case UIApplicationState.background:
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
        
        newRecord(messageStringFinal, alert: isAlert, messageID: messageIDFinal)
        
        // finished
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveManagedObjectContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {
        saveManagedObjectContext()
    }
    
    // MARK: -
    // MARK: Core Data Stack
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main().urlForResource("Swift_Push", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let persistentStoreCoordinator = self.persistentStoreCoordinator
        
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // URL Documents Directory
        let URLs = FileManager.default().urlsForDirectory(.documentDirectory, inDomains: .userDomainMask)
        let applicationDocumentsDirectory = URLs[(URLs.count - 1)]
        
        // URL Persistent Store
        let URLPersistentStore = try! applicationDocumentsDirectory.appendingPathComponent("Done.sqlite")
        
        do {
            // Add Persistent Store to Persistent Store Coordinator
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: URLPersistentStore, options: nil)
            
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
