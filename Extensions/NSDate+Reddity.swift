//
//  NSDate+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-27.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

extension NSDate {
    class func describePastTimeInDays(past: NSDate) -> String {
        let days = Int(abs(past.timeIntervalSinceNow) / (24 * 3600))
        
        if days == 0 {
            return "Today"
        } else if days < 30 {
            let unit = days < 2 ? "day" : "days"
            return "\(String(days)) \(unit) ago"
        } else if 31...365 ~= days {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM-dd"
            return formatter.stringFromDate(past)
        } else {
            return "One year ago"
        }
    }

    /**
     Return the date string in sqlite format  
     */
    class func sqliteDate(aDate: NSDate = NSDate()) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.stringFromDate(aDate)
    }
}
