//
//  AppDelegate.swift
//  Swift Push
//
//  Created by steve on 01/07/2014.
//  Copyright (c) 2014 Trease. All rights reserved.
//

import UIKit
import Foundation
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var tableView: UITableView!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        
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
        if ( existingToken as String == deviceToken.description as String ) {
             println("device token unchanged")
        } else {
            println("device token changed and saved")
            NSUserDefaults.standardUserDefaults().setObject(deviceToken.description as String, forKey:"deviceToken")
            // NSUserDefaults.standardUserDefaults().synchronize()
        }
        println(deviceToken.description)
        println()
    }
    
    
    func application(application: UIApplication!, didFailToRegisterForRemoteNotificationsWithError error:NSError!) {
        println("Failed to recieve device token")
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
        
        notifications.insert(item, atIndex: 0)
        if (notifications.count > 10) {
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
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.\
        println("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        println("applicationWillEnterForeground")
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        println("applicationDidBecomeActive")
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        println("applicationWillTerminate")
    }


}

