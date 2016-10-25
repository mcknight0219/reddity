//
//  TopicTableViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

class TopicTableViewController: BaseTableViewController {

    var dataSource: TopicDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: animated)
        }
    }
    
}

// MARK: Table view data source delegate

extension TopicTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataSource!.numberOfSectionsInTableView(tableView)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource!.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.dataSource!.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
}

// MARK Table view delegate

extension TopicTableViewController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let aLink = self.dataSource.topicAtIndexPath(indexPath)!
        
        switch aLink.type() {
        case .Image:
            if aLink.ratio > 0 {
                let imageHeight = Float((UIScreen.mainScreen().bounds.width - 20)) / aLink.ratio
                
                return CGFloat(imageHeight) + 120.0
            } else {
                return 270
            }
        case .News:
            return 180
        default:
            return 120
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let aLink = self.dataSource.topicAtIndexPath(indexPath)!

        let detailsVC = DetailsViewController(aSubject: aLink)
        detailsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // Prefetch early
        if offsetY > scrollView.contentSize.height - scrollView.frame.size.height - 350 {
            NSNotificationCenter.defaultCenter().postNotificationName("NeedTopicPrefetchNotification", object: nil)
        }
    }
}
