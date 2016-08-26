//
//  AppDelegate.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
import FMDB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /**
     The global database handler
     */
    var database: FMDatabase?

    /**
     Current user.
     
     @discussion The `guest` is the user without logging into reddit.com
     */
    var user: String = 'guest'

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
        
        let isFirstTime = NSUserDefaults.standardUserDefaults().objectForKey("isFirstTime") as? Bool ?? true
        let isLoggedin = NSUserDefaults.standardUserDefaults().objectForKey("isLoggedin") as? Bool ?? false
        self.openDB(isFirstTime)
        
        if isFirstTime || !isLoggedin {
            if isFirstTime { NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isFirstTime") }
            
            let startVC = StartupViewController()
            startVC.modalTransitionStyle = .FlipHorizontal
            presentVC(startVC, withToken: false)
            
            return true
        }
        ReachabilityManager.sharedInstance?.startMonitoring()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.pushTabbar), name: "PushInTabBarAfterStartup", object: nil)
        
        self.pushTabbar()
        return true
    }
    
    @objc func pushTabbar() {
        let tabBarVC = UITabBarController()

        func embedInNav(vc: UIViewController) -> UINavigationController {
            return NavigationController(rootViewController: vc)
        }

        let searchVC = SearchViewController()
        searchVC.modalTransitionStyle = .CoverVertical
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage.fontAwesomeIconWithName(.Search, textColor: FlatOrange(), size: CGSizeMake(37, 37)), tag: 0)
        
        let homeVC = HomeViewController(subredditName: "")
        homeVC.modalTransitionStyle = .CrossDissolve
        homeVC.tabBarItem = UITabBarItem(title: "Browse", image: UIImage.fontAwesomeIconWithName(.Home, textColor: FlatOrange(), size: CGSizeMake(37, 37)), tag: 1)

        let subscriptionVC = SubscriptionViewController()
        subscriptionVC.modalTransitionStyle = .CrossDissolve
        subscriptionVC.tabBarItem = UITabBarItem(title: "List", image: UIImage.fontAwesomeIconWithName(.List, textColor: FlatOrange(), size: CGSizeMake(37, 37)), tag: 2)
        
        let meVC = MeViewController()
        meVC.modalTransitionStyle = .CrossDissolve
        meVC.tabBarItem = UITabBarItem(title: "Me", image: UIImage.fontAwesomeIconWithName(.User, textColor: FlatOrange(), size: CGSizeMake(37, 37)), tag: 3)

        tabBarVC.viewControllers = [embedInNav(searchVC), embedInNav(homeVC), embedInNav(subscriptionVC), embedInNav(meVC)]
        // Select Browse tab on starup
        tabBarVC.selectedIndex = 1
        tabBarVC.tabBar.tintColor = FlatOrange()

        self.presentVC(tabBarVC, withToken: true)
    }

    /**
     Present the view controller
     
     - parameter vc:        the view controller to present
     - parameter withToken: if the presentation needs wrapped in token service
     
     */
    func presentVC(vc: UIViewController, withToken: Bool) {
        self.window?.rootViewController = vc
        if withToken {
            TokenService.sharedInstance.withAccessToken {
                self.window?.makeKeyAndVisible()
            }
        } else {
            self.window?.makeKeyAndVisible()
        }   
    }

    /**
     Open database and create necessary table if first time run.

     - parameter createTables:   Whether to create the scheme.
     */
    func openDB(createTables: Bool) {
        let fileURL = try! FileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false).URLByAppendingPathComponent("app.sqlite")
        database = FMDatabase(path: fileURL.path)
        if !database.open() {
            print("Unable to open database")
            return
        }

        if createTables {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {        
                do {
                    try self.database.executeUpdate("CREATE TABLE users(id TEXT PRIMARY KEY, timestamp TEXT)")
                    try self.database.executeUpdate("CREATE TABLE search_history(term TEXT, timestamp TEXT, FOREIGN KEY(user) REFERENCES users(id))", values: nil)
                    try self.database.executeUpdate("CREATE TABLE subscriptions(id INTEGER PRIMARY KEY, FOREIGN KEY(user) REFERENCES users(id), FOREIGN KEY(subreddit) REFERENCES subreddits(id), timestamp TEXT)", values: nil)
                    try self.database.executeUpdate("CREATE TABLE subreddits(id PRIMARY KEY TEXT, name TEXT, title TEXT, displayName TEXT, subscribers INT, imageURL: TEXT)", values: nil)

                    // Always create `guest` user.
                    try self.database.executeUpdate("INSERT INTO users (id, timestamp) values (?, ?)", values: ["guest", NSDate.sqliteDate()])
                } catch let error as NSError {
                    print("failed: \(error.localizedDescription)")
                }
            }
        }
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
        database?.close()
    }


}

