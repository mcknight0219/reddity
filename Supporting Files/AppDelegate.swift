//
//  AppDelegate.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import FMDB
import ChameleonFramework


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /**
     The global database handler
     */
    var database: FMDatabase?
    
    var disposeBag = DisposeBag()
    var provider = Networking.newNetworking()

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let result = url.query?.componentsSeparatedByString("&").reduce([:]) { (result: [String: String], q: String) in
            let arr = q.componentsSeparatedByString("=")
            var dict = result
            dict[arr[0]] = arr[1]
            return dict
        }
        
        if let queryParams = result, let code = queryParams["code"] {
            /// time to acquire refresh token
            let networking = Networking.newNetworking()
            var token = XAppToken()
            networking.request(.XApp(grantType: .Code, code: code))
                .filterSuccessfulStatusCodes()
                .mapJSON()
                .map { element -> (refresh: String?, access: String?, expiry: Int?) in
                    guard let dict = (element as? NSDictionary) else { return (nil, nil, nil) }
                    
                    return (refresh: dict["refresh_token"] as? String, access: dict["access_token"] as? String, expiry: dict["expires_in"] as? Int)
                }
                .doOn { event in
                    guard case Event.Next(let e) = event else { return }
      
                    token.refreshToken = e.0
                    token.accessToken  = e.1
                    token.expiry = NSDate().dateByAddingTimeInterval(Double(e.2!))
                }
                .subscribeNext { _, _, _ in
                    networking.request(.Me)
                        .filterSuccessfulStatusCodes()
                        .mapJSON()
                        .map { element -> String? in
                            guard let dict = element as? NSDictionary else { return "guest" }
                            return dict["name"] as? String
                        }
                        .subscribeNext { name in
                            var account = Account()
                            account.user = AccountType.LoggedInUser(name: name!)
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("OAuthFinishedNotification", object: NSNumber(int: 1))
                        }
                        .addDisposableTo(self.disposeBag)
                }
                .addDisposableTo(self.disposeBag)
            

        } else {

            NSNotificationCenter.defaultCenter().postNotificationName("OAuthFinishedNotification", object: NSNumber(int: 0))
        }
        
        return true
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.pushTabbar), name: "PushInTabBarAfterStartup", object: nil)
        
        var account = Account()
        
        let isPristine = account.isPristine
        self.openDB(isPristine)
        self.newStorage(isPristine)
        
        if isPristine {
    
            account.user = .Guest
            
            let startVC = StartupViewController()
            startVC.modalTransitionStyle = .FlipHorizontal
            presentVC(startVC)
            
            return true
        }
        
        self.pushTabbar()
        return true
    }
    
    @objc func pushTabbar() {
        let tabBarVC = TabBarController()

        let searchVC: SearchViewController = {
            $0.modalTransitionStyle = .CoverVertical
            //$0.tabBarItem = UITabBarItem(title: "Search", image: UIImage.fontAwesomeIconWithName(.Search, textColor: UIColor.blackColor(), size: CGSizeMake(37, 37)), tag: 0)
            $0.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "tabbar_search"), tag: 0)
            $0.tabBarItem.selectedImage = UIImage(named: "tabbar_search_selected")
            $0.provider = provider
            return $0
        }(SearchViewController())
        
        let homeVC: TimelineViewController = {
            $0.modalTransitionStyle = .CrossDissolve
            //$0.tabBarItem = UITabBarItem(title: "Browse", image: UIImage.fontAwesomeIconWithName(.Home, textColor: UIColor.blackColor(), size: CGSizeMake(37, 37)), tag: 1)
            $0.tabBarItem = UITabBarItem(title: "Browse", image: UIImage(named: "tabbar_home"), tag: 1)
            $0.provider = provider
            
            return $0
        }(TimelineViewController(subredditName: ""))
        
        let subscriptionVC: SubscriptionViewController = {
            $0.modalTransitionStyle = .CrossDissolve
            //$0.tabBarItem = UITabBarItem(title: "List", image: UIImage.fontAwesomeIconWithName(.List, textColor: UIColor.blackColor(), size: CGSizeMake(37, 37)), tag: 2)
            $0.tabBarItem = UITabBarItem(title: "Subscriptions", image: UIImage(named: "tabbar_list"), tag: 2)
            $0.provider = provider
            
            return $0
        }(SubscriptionViewController())

        let meVC: MeViewController = {
            $0.modalTransitionStyle = .CrossDissolve
            //$0.tabBarItem = UITabBarItem(title: "Me", image: UIImage.fontAwesomeIconWithName(.Cog, textColor: UIColor.blackColor(), size: CGSizeMake(37, 37)), tag: 3)
            $0.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "tabbar_setting"), tag: 0)
            return $0
        }(MeViewController(style: .Grouped))

        tabBarVC.viewControllers = [homeVC, subscriptionVC, searchVC, meVC].map {
            NavigationController(rootViewController: $0)
        }
        // Select Browse tab on starup
        tabBarVC.selectedIndex = 0
        tabBarVC.tabBar.tintColor = FlatBlue()

        self.presentVC(tabBarVC)
    }

    /**
     Present the view controller
     
     - parameter vc:        the view controller to present
     
     */
    func presentVC(vc: UIViewController) {
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }

    lazy var storagePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        .stringByAppendingString("/Data")

    func newStorage(isFirstTime: Bool) {
        if !isFirstTime { return }
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(self.storagePath, withIntermediateDirectories: false, attributes: nil)
        } catch let err as NSError {
            print("failed: \(err.localizedDescription)")
        }
    }

    /**
     Open database and create necessary table if first time run.

     - parameter createTables:   Whether to create the scheme.
     */
    func openDB(createTables: Bool) {
        let fileURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false).URLByAppendingPathComponent("app.sqlite")
        database = FMDatabase(path: fileURL!.path)
        if !database!.open() {
            print("Unable to open database")
            return
        }

        if createTables {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {        
                do {
                    try self.database!.executeUpdate("CREATE TABLE users(id TEXT PRIMARY KEY, timestamp TEXT)", values: nil)
                    try self.database!.executeUpdate("CREATE TABLE search_history(term TEXT, timestamp TEXT, scope INT, user TEXT, FOREIGN KEY(user) REFERENCES users(id))", values: nil)
                    try self.database!.executeUpdate("CREATE TABLE subreddits(id TEXT PRIMARY KEY, name TEXT, title TEXT, displayName TEXT, subscribers INT, imageURL TEXT)", values: nil)
                    try self.database!.executeUpdate("CREATE TABLE subscriptions(id INTEGER PRIMARY KEY, user TEXT, subreddit TEXT, timestamp TEXT, FOREIGN KEY(user) REFERENCES users(id), FOREIGN KEY(subreddit) REFERENCES subreddits(id))", values: nil)

                    // Always create `guest` user.
                    try self.database!.executeUpdate("INSERT INTO users (id, timestamp) values (?, ?)", values: ["guest", NSDate.sqliteDate()])
                } catch let error as NSError {
                    print("failed: \(error.localizedDescription)")
                }
            }
        }
    }

    /**
     *  Clean up the database. 
     *  
     * @parameter  deleteTables     Whether to delete tables when cleaning up
     * @discussion This is mostly for debugging purpose.
     */
    private func cleanUpDB(deleteTables: Bool = false) {
        if let db = self.database {
            ["users", "search_history", "subreddits", "subscriptions"].forEach { tn in
                do {
                    if deleteTables { try db.executeUpdate("DROP TABLE IF EXISTS \(tn)", values: nil) }
                    else { try db.executeUpdate("TRUNCATE TABLE \(tn)", values: nil) }
                } catch let error as NSError {
                        print("failed: \(error.localizedDescription)")
                }
            }
            return
        }
        print("failed: database is not opened.")
    }

    /**
     * Add or remove database tables in development. 
     *
     * @discussion this is for debugging purpose.
     */
    private func migrateDB() {
        if let db = self.database {
            do {
                try db.executeUpdate("CREATE TABLE offline_data(data TEXT, subreddit TEXT, timestamp TEXT, FOREIGN KEY(subreddit) REFERENCES subreddits(id)", values: nil)
            } catch let err as NSError {
                print("failed: \(err.localizedDescription)")
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
        NSNotificationCenter.defaultCenter().postNotificationName("ArchiveTimelineHistory", object: nil)
        database?.close()
    }
}

