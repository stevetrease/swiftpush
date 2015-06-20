//
//  AppDelegate.swift
//  Swift Push 4
//
//  Created by Steve Trease on 16/06/2015.
//  Copyright © 2015 Steve Trease. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        let versionNumber: AnyObject? = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"]
        print ("version \(versionNumber!)")
        
        let item = NotificationData()
        item.alert = "Swift Push (\(versionNumber!)) starting on " + UIDevice.currentDevice().name
        notifications.insert(item, atIndex: 0)
        
        switch (application.applicationState) {
        case UIApplicationState.Active:
            print ("didFinishLaunchingWithOptions - active")
        case UIApplicationState.Inactive:
            print ("didFinishLaunchingWithOptions - inactive")
        case UIApplicationState.Background:
            print ("didFinishLaunchingWithOptions - background")
        }
        
        let types: UIUserNotificationType =
        [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        
        let settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
        
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()
        
        // screenshot notification
        let mainQueue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationUserDidTakeScreenshotNotification, object: nil, queue: mainQueue) { notification in
            print("screenshot taken")
        }
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
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.trease.eu/ibeacon/swiftpush/")!)
        request.HTTPMethod = "POST"
        var bodyData = "token=\(deviceToken.description)"
        bodyData += "&device=\(UIDevice.currentDevice().name)"
        bodyData += "&mode=\(mode!)"
        bodyData += "&version=\(versionNumber!)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            let x = response as? NSHTTPURLResponse
            print ("status code \(x?.statusCode)")
        }
        task!.resume()
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
        
        let item = NotificationData()
        
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? String {
                item.alert = alert
                print ("alert: \(alert)")
            }
        }
        if let messageID = userInfo["messageID"] as? Int {
            item.messageID = messageID
            print ("messageID: \(messageID)")
        }
        if let timeStamp = userInfo["timestamp"] as? NSTimeInterval {
            item.timeStampSent = NSDate (timeIntervalSince1970: timeStamp)
            print ("timestamp: \(timeStamp)")
        }
        
        notifications.insert(item, atIndex: 0)
        if (notifications.count > maxNotifications) {
            notifications.removeLast()
        }
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName("dataChanged", object: self)
        
        // finished
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
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}

