//
//  NSDate+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-27.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

extension Date {
    func daysAgo() -> String {
        let days = Int(abs(self.timeIntervalSinceNow) / (24 * 3600))
        
        if days == 0 {
            return "Today"
        } else if days < 30 {
            return "\(String(days))d"
        } else if 31...365 ~= days {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd"
            return formatter.string(from: self)
        } else {
            return "One year ago"
        }
    }
    
    func minutesAgo() -> String {
        let time = self.daysAgo()
        guard time == "Today" else { return time }
        
        let hours = Int(abs(self.timeIntervalSinceNow) / (3600))
        if hours > 1 {
            return "\(hours)h"
        } else {
            return "\(Int(abs(self.timeIntervalSinceNow) / 60))m"
        }
    }

    /**
     Return the date string in sqlite format  
     */
    static func sqliteDate(aDate: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: aDate)
    }
}
