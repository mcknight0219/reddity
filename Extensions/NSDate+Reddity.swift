//
//  NSDate+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-27.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

extension NSDate {
    func daysAgo() -> String {
        let days = Int(abs(self.timeIntervalSinceNow) / (24 * 3600))
        
        if days == 0 {
            return "Today"
        } else if days < 30 {
            let unit = days < 2 ? "day" : "days"
            return "\(String(days)) \(unit) ago"
        } else if 31...365 ~= days {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM-dd"
            return formatter.stringFromDate(self)
        } else {
            return "One year ago"
        }
    }
    
    func minutesAgao() -> String {
        let time = self.daysAgo()
        guard time == "Today" else { return time }
        
        let hours = Int(abs(self.timeIntervalSinceNow) / (3600))
        if hours > 1 {
            return "\(hours) hours ago"
        } else {
            return "\(Int(abs(self.timeIntervalSinceNow) / 60)) minutes ago"
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
