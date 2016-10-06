//
//  TimelineDownloadOperation.swift
//  Reddity
//
//  Created by Qiang Guo on 16/10/4.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import UIKit
import SwiftyJSON

class TimelineDownloadOperation: NSOperation {
    let subreddit: Subreddit
    
    var maximumArticles = 25

    lazy var db = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).database!
    }()
    
    init(subreddit: Subreddit, max: Int?) {
        self.subreddit = subreddit
        if let max = max { maximumArticles = max }
    }
    
    override func main() {
        guard !self.cancelled else { return }
        let resource = Resource(url: "/r/\(subreddit.displayName)/hot", method: .GET, linkParser)
        
        apiRequest(Config.ApiBaseURL, resource: resource, params: ["limit": "\(self.maximumArticles)"]) { links -> Void in
            guard links != nil else { return }
            
            links.forEach { link in
                do {
                    try db.executeUpdate("INSERT INTO offline_data(data, subreddit, timestamp) values(?, ?, ?)", values: [l.rawJsonString!, l.subreddit, NSDate.sqliteDate()])
                } catch let err as NSError {
                    print("failed: \(err.localizedDescription)")
                }

            }
        }
    }
    
}
