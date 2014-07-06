//
//  AppDelegate.swift
//  Swift Push
//
//  Created by steve on 01/07/2014.
//  Copyright (c) 2014 Trease. All rights reserved.
//

import UIKit
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
    var tableView: UITableView!
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        
        println("didFinishLaunchingWithOptions")
        // println(notifications.items.count)
        
        var types: UIUserNotificationType = UIUserNotificationType.Badge |
            UIUserNotificationType.Alert |
            UIUserNotificationType.Sound
        
        var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
        
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()

        // set default device token preference
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "deviceToken")
        return true
    }

    
    func application(application: UIApplication!, didRegisterForRemoteNotificationsWithDeviceToken deviceToken:NSData!) {
        var existingToken: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken")
        if ( existingToken as String == deviceToken.description as String ) {
            println("device token unchanged")
        } else {
            println("device token changed and saved")
            NSUserDefaults.standardUserDefaults().setObject(deviceToken.description, forKey:"deviceToken")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        println(deviceToken.description)
        println()

    }
    func application(application: UIApplication!, didFailToRegisterForRemoteNotificationsWithError error:NSError!) {
        println("Failed to recieve device token")
        println( error.localizedDescription )
    }
    func application(application: UIApplication!, didReceiveRemoteNotification userInfo:NSDictionary) {
        println(userInfo)
        var t1: AnyObject! = userInfo.objectForKey("aps")
        var message = t1.objectForKey("alert") as String
        notifications.items.append(message)
        notifications.items.insert(message, atIndex: 0)
        println ("Push message received by AppDeligate: \(message)")
        
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName("dataChanged", object: self)
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

