//
//  AppDelegate.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.pushTabbar), name: "PushInTabBarAfterStartup", object: nil)
        
        let isFirstTime = NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") as? Bool ?? true
        
        if isFirstTime {
            NSUserDefaults().setObject(false, forKey: "FirstTime")
            let startVC = StartupViewController()
            startVC.modalTransitionStyle = .FlipHorizontal
            
            self.presentVC(startVC, withToken: false)
            
            return true
        }
        ReachabilityManager.sharedInstance?.startMonitoring()

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
        
        let homeVC = HomeViewController(channel: "")
        homeVC.modalTransitionStyle = .CrossDissolve
        homeVC.tabBarItem = UITabBarItem(title: "Browse", image: UIImage.fontAwesomeIconWithName(.Home, textColor: FlatOrange(), size: CGSizeMake(37, 37)), tag: 1)

        let meVC = MeViewController()
        meVC.modalTransitionStyle = .CrossDissolve
        meVC.tabBarItem = UITabBarItem(title: "Me", image: UIImage.fontAwesomeIconWithName(.User, textColor: FlatOrange(), size: CGSizeMake(37, 37)), tag: 2)

        tabBarVC.viewControllers = [searchVC, homeVC, meVC].map { embedInNav($0) }
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

