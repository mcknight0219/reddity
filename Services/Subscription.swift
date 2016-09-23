//
//  Subscription.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-09-09.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import FMDB

let kUserChangedNotification  = "UserChangedNotification"
let kSubscriptionsChangedNotification = "SubscriptionsChangedNotification"

/**
 This class manages the subscribed subreddits for user. If user is logged in, it will synchronizes
 to reddit service on behalf of the user; otherwise, the `guest` user maintains a subscription list
 on the local disk.
 */
class Subscription {

    static let sharedInstance = Subscription()

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
            if oldValue.elementsEqual(subs, isEquivalent: { $0 == $1 }) {
                 NSNotificationCenter.defaultCenter().postNotificationName(kSubscriptionsChangedNotification, object: nil)
            }
            
            self.flags.removeAll()
            for sub in subs { self.flags[sub.id] = .Normal }
        }
    }

    /**
     The status of a subscribed item
     */
    enum Status {
        case New        // newly subscribed, need to be synchronized to local storage and remote
        case Deleted    // deleted, need to be synchronized to local storage
        case Normal     // no need to be synchronized
    }
    
    /**
     An dictionary of statuses for subscribed items in`sub`
     */
    var flags = [String: Status]()

    
    // MARK: - Initializer
    
    init() {
        self.user = app.user
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Subscription.updateSubscription(_:)), name: kUserChangedNotification, object: nil)
        // send notification immediately since we need to get subscription
        NSNotificationCenter.defaultCenter().postNotificationName(kUserChangedNotification, object: self.user)
    }

    
    @objc func updateSubscription(note: NSNotification) {
        let newUser = note.object as! String
        guard newUser != user else {
            return
        }

        self.findSubscriptionsFor(newUser)
    }
    
    
    // MARK: - Public functions
    
    func subscribeTo(aSubreddit subreddit: Subreddit) -> Bool {
        // Check if subscribing to an existing element
        for sub in subs {
            if sub == subreddit {
                let id = subreddit.id
                if flags[id]! == .Deleted {
                    flags[id] = .Normal
                }
                return true
            }
        }
        self.subs.append(subreddit)
        self.flags[subreddit.id] = .New
        
        return true
    }
    
    func unsubscribe(aSubreddit subreddit: Subreddit) -> Bool {
        for sub in subs {
            if sub == subreddit {
                if flags[sub.id]! == .New {
                    // remove an unsynchronized item, so just remove it entirely
                    flags.removeValueForKey(sub.id)
                    subs.removeAtIndex(subs.indexOf(sub)!)
                } else {
                    flags[sub.id]! = .New
                }
                
                return true
            }
        }
        print("failed: \(subreddit.displayName) is not subscribed")
        
        return false
    }
    
    
    // MARK: - Implementation
    

    private func findSubscriptionsFor(user: String) {
        if user == "guest" {
            self.subs = self.unserializeFromDB("guest")
            return
        }

        let subscriptionResource = Resource(url: "/subreddits/mine/subscriber", method: .GET, parser: subredditsParser)
        apiRequest(Config.ApiBaseURL, resource: subscriptionResource, params: nil) { (subs) -> Void in
            if let subs = subs {
                
                self.serializeToDB(subs, user: user)
            }
            
            // If sync fails, fallback to database
            self.subs = self.unserializeFromDB(user)
        }

    }

    private func unserializeFromDB(user: String) -> [Subreddit] {
        var ret = [Subreddit]()
        executeInDatabase { db in
            let rs = try db.executeQuery("SELECT * FROM subreddits AS sr " +
                "JOIN subscriptions AS sp ON sp.subreddit = sr.id " +
                "WHERE sp.user = ?", values: [self.user])
            
            while rs.next() {
                ret.append(createSubredditFromQueryResult(rs))
            }
        }
        
        return ret
    }
    
    private func serializeToDB(data: [Subreddit], user: String) {
        
    }
    
    private func isSubscribedTo(subreddit: String, user: String) -> Bool {
        var ret = false
        executeInDatabase { db in
            let rs = try db.executeQuery("SELECT id FROM subscriptions WHERE subreddit = ? AND user = ?", values: [subreddit, user])
            ret = rs.next()
        }
        
        return ret
    }
    
    private func executeInDatabase(queryClosure: (FMDatabase) throws -> Void) -> Bool {
        if let db = app.database {
            do {
                try queryClosure(db)
            } catch let err as NSError {
                print("failed: \(err.localizedDescription)")
                return false
            }
            return true
        }
        
        return false
    }
   
}
