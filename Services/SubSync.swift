//
//  SubSync.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-09-09.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

let kUserChangedNotification  = "UserChangedNotification"
let kSubscriptionsChangedNotification = "SubscriptionsChangedNotification"

/**
 This class manages the subscribed subreddits for user. If user is logged in, it will synchronizes
 to reddit service on behalf of the user; otherwise, the `guest` user maintains a subscritpion list
 on the local disk.
 */
class SubSync {

    /**
     Get the app instance lazily
     */
    lazy var app: AppDelegate = {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }()

    /**
     The current user of app. It's the username if logged in, `guest` otherwise.
     */
    var user: String!

    /**
     The list of subscribed subreddit for current user
     */
     var subs = [Subreddit]() {
         didSet {
             if oldValue != subs {
                 NSNotificationCenter.defaultCenter().postNotificationName(kSubscriptionsChangedNotification, object: subs)
             }
         }
     }

    init() {
        self.user = app.user 

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SubSync.userDidChange(:), name: kUserChangedNotification, object: nil)
    }

    
    func userDidChange(note: NSNotification) {
        let newUser = note.object as! String
        guard newUser != user else {
            return
        }
    }

    private func findSubscriptionsFor(user user: String) {
        if user == "guest" {
            self.loadSubscriptionsFromDB("guest")
            return
        }

        let subscriptionResource = Resource(url: "/subreddits/mine/subscriber", method: .GET, parser: subredditsParser)
        apiRequest(Config.ApiBaseURL, resource: subscriptionResource, params: nil) { [weak self]  (subs) -> Void in
            
        }

    }

    private func loadSubscriptionsFromDB(user: String) {
        guard !user.isEmpty else {
            return
        }
        // Get a clean state
        subs.removeAll()

        if let db = app.database {
            try {
                let rs = db.executeQuery("SELECT * FROM subreddits AS sr " +
                    "JOIN subscriptions AS sp ON sp.subreddit = sr.id " +
                    "WHERE sp.user = ?", values: [self.user])

        while rs.next() {
            self.subs.append(createSubredditFromQueryResult(rs))           
        }
            } catch let err as! NSError {
                print("failed: \(err.localizedDescrition)")
            }
        }
    }
   
}
