//
//  TopicController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-25.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc protocol TopicControllerDelegate {
    optional func topicControllerDidFinishLoading(topicController: TopicController)
    optional func topicControllerDidFailedLoading(topicController: TopicController)
}

class TopicController: NSObject {
    
    // MARK: Properties
    
    var delegate: TopicControllerDelegate?
    
    lazy var topics: [Link] = {
       return [Link]()
    }()
    
    var busy: Bool = false
    var subreddit: String = "" {
        didSet {
            if subreddit.isEmpty {
                self.subredditPath = "/"
            } else {
                self.subredditPath = "/r/\(subreddit)"
            }
            
            self.reload()
        }
    }
    
    var subredditPath: String = "/"
    
    func changeSubreddit(notification: NSNotification) {
        if let sub = notification.object as? String {
            self.subreddit = sub
        }
    }
    
    func reload() {
        guard !busy else { return }
        self.busy = true
        
        let linksResource = Resource(url: self.subredditPath, method: .GET, parser: linkParser)
        apiRequest(Config.ApiBaseURL, resource: linksResource, params: ["raw_json": "1"]) { links -> Void in
            if let links = links {
                self.topics = links
                self.delegate?.topicControllerDidFinishLoading?(self)
            } else {
                self.delegate?.topicControllerDidFailedLoading?(self)
            }
            
            self.busy = false
        }
    }
    
    func prefetch() {
        guard !busy else { return }
        guard self.topics.count > 0 else { return }
        
        self.busy = true
        
        let linksResource = Resource(url: self.subredditPath, method: .GET, parser: linkParser)
        apiRequest(Config.ApiBaseURL, resource: linksResource, params: ["raw_json": "1", "after": afterName ?? ""]) { links -> Void in
            if let links = links {
                self.topics.appendContentsOf(links)
                self.delegate?.topicControllerDidFinishLoading?(self)
            } else {
                self.delegate?.topicControllerDidFailedLoading?(self)
            }
            
            self.busy = false
        }
    }
    
}
