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
    
    init(subreddit: Subreddit, max: Int?) {
        self.subreddit = subreddit
        if let max = max { maximumArticles = max }
    }
    
    override func main() {
        guard !self.cancelled else { return }
        // don't filter out data right now, just download and save them.
        let resource = Resource(url: "/r/\(subreddit.displayName)/hot", method: .GET) { json -> String in
            return json.rawString()!
        }
        
        apiRequest(Config.ApiBaseURL, resource: resource, params: ["limit": "\(self.maximumArticles)"]) { data -> Void in
            guard data != nil else { return }
            self.extractResource(data!)
            
            let app = UIApplication.sharedApplication().delegate as! AppDelegate
            do {
                try app.database!.executeUpdate("INSERT INTO offline_data(data, subreddit, timestamp) values(?, ?, ?)", values: [])
            } catch let err as NSError {
                print("failed: \(err.localizedDescription)")
            }
        }
    }
    
    func extractResource(data: String) {
        linkParser(JSON(data)).forEach { l in
            if l.type() == .Image || l.type() == .Video  {
                let op = ResourceDownloadOperation(URL: l.url)
                self.addDependency(op)
                NSOperationQueue.mainQueue().addOperation(op)
            }
        }
    }
}
