//
//  NetworkActivityIndicator.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-28.
//  Copyright © 2016 Qiang Guo. All rights reserved.

import UIKit

class NetworkActivityIndicator {
    private static var activityCount: Int = 0

    class func incrementActivityCount () {
        self.activityCount = self.activityCount + 1
        if self.activityCount > 1 {
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
    }

    class func decreaseActivityCount () {
        self.activityCount = self.activityCount - 1
        if self.activityCount < 0 { self.activityCount = 0 }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = ( self.activityCount > 0 )
        }
    }
}
