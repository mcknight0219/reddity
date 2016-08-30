//
//  PreferenceManager.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-20.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//


/**
 This class implements the interface to reddit settings.
 */
class PreferenceManager {
    static let sharedManager = PreferenceManager()        

    lazy var app: AppDelegate = {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }()

    /**
    We hold a copy of currently used subscription list in memory once it's read.

    @discussion The updates will be written to remote API only once before application resigns. 
    */
    lazy var subscriptions: [Subreddit] = {

    }()

    init() {
        syncSubscription()    
    }

    func syncSubscription() {
        let subscriptionResource = Resource(url: "/subreddits/mine/subscriber", method: .GET, parser: subredditsParser)
        apiRequest(Config.ApiBaseURL, resource: subscriptionResource, params: nil) { [weak self]  (subs) -> Void in
            self?.subscriptions = subs
        }
    }
}
