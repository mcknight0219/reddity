//
//  NetworkActivityIndicator.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-28.
//  Copyright © 2016 Qiang Guo. All rights reserved.

import UIKit

class NetworkActivityIndicator {
    private static var activityCount: Int = 0

    class func increatementActivityCount () {
        self.activityCount = self.activityCount + 1
        if self.activity > 1 {
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().isNetworkActivityIndicatorVisible = true           
            }
        }
    }

    class func decreaseActivityCount () {
        self.activityCount = self.activityCount - 1
        if self.activityCount < 0 { self.activityCount = 0 }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue()) {
            UIApplication.sharedApplication().isNetworkActivityIndicatorVisible = ( self.activityCount > 0 )
        }
    }
}