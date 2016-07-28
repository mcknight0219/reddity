//
//  AppDelegate.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let result = url.query?.componentsSeparatedByString("&").reduce([:]) { (result: [String: String], q: String) in
            let arr = q.componentsSeparatedByString("=")
            var dict = result
            dict[arr[0]] = arr[1]
            return dict
        }
        
        if let queryParams = result, let code = queryParams["code"] {
            TokenService.sharedInstance.code = code
            NSNotificationCenter.defaultCenter().postNotificationName("OAuthFinishedNotification", object: NSNumber(int: 1))
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("OAuthFinishedNotification", object: NSNumber(int: 0))
        }
        
        
        return true
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let isFirstTime = NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") as? Bool ?? true
        if isFirstTime {
            NSUserDefaults().setObject(false, forKey: "FirstTime")
            let startVC = StartupViewController()
            startVC.modalTransitionStyle = .FlipHorizontal
            self.window?.rootViewController = startVC
        } else {
            TokenService.sharedInstance.withAccessToken {
                let mainVC = HomeViewController()
                mainVC.modalTransitionStyle = .CrossDissolve
                
                let navigationController = NavigationController(rootViewController: mainVC)
                let tabBarController = UITabBarController()
                tabBarController.viewControllers = [navigationController]
                self.window?.rootViewController = tabBarController
            }
        }
        self.window?.makeKeyAndVisible()
        
        return true
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


}

