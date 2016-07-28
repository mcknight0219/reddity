//
//  TopicDataSource.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-25.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class TopicDataSource: NSObject {
    
    var cellIdentifier: String?
    
    var topics: [Link]?
    
    override init() {
        super.init()
    }
    
    func topicAtIndexPath(index: NSIndexPath) -> Link? {
        guard self.topics != nil && self.topics?.count >= index.row else {
            return nil
        }
        
        return self.topics![index.row]
    }
}

// MARK: UITableViewDataSource

extension TopicDataSource: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let content = self.topics where !content.isEmpty else {
            return 0
        }
    
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let content = self.topics where !content.isEmpty else {
            return 0
        }
        
        return content.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let type = self.topicAtIndexPath(indexPath)!.type()
        
        switch type {
        case .Image:
            let cell = tableView.dequeueReusableCellWithIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
            cell.loadTopic(self.topics![indexPath.row])
            return cell
        case .News:
            let cell = tableView.dequeueReusableCellWithIdentifier("NewsCell", forIndexPath: indexPath) as! NewsCell
            cell.loadTopic(self.topics![indexPath.row])
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextCell", forIndexPath: indexPath) as! TextCell
            cell.loadTopic(self.topics![indexPath.row])
            return cell
        }
    }
}
