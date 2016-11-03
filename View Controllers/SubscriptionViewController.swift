//
//  SubscriptionViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-02
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class SubscriptionViewController: BaseTableViewController {

    var subscriptions = [Subreddit]() {
        didSet {
            if self.subscriptions.count > 0 {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(SubscriptionViewController.mixTimelines))
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }

    var background: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Subscription"
        navigationController?.navigationBar.titleTextAttributes![NSFontAttributeName] = UIFont(name: "Lato-Regular", size: 20)!
        
        let footer = UIView()

        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.tableFooterView = footer

        let background = UIView()
        let label = UILabel()
        label.text = "You don't have any subscription yet."
        label.font = UIFont(name: "Lato-Regular", size: 18)!
        label.textColor = FlatWhiteDark()
        label.numberOfLines = 0
        label.textAlignment = .Center
        background.addSubview(label)
        label.snp_makeConstraints { make in
            make.leading.equalTo(background).offset(25)
            make.trailing.equalTo(background).offset(-25)
            make.top.equalTo(UIScreen.mainScreen().bounds.height / 2 - 150)
        }

        if subscriptions.count == 0 {
            tableView.backgroundView = background
        }
        
        let subscriptionResource = Resource(url: "/subreddits/mine/subscriber", method: .GET, parser: subredditsParser)
        apiRequest(Config.ApiBaseURL, resource: subscriptionResource, params: ["limit": String(100)]) { (subs) -> Void in
            if let subs = subs {
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.subscriptions = subs
                    
                    self.tableView.reloadData()
                }

            }
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SubscriptionViewController.showBackgroundView), name: "PreferenceChanged", object: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionCell")
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "SubscriptionCell")
        }

        let sub = self.subscriptions[indexPath.row]
        cell!.textLabel?.text = sub.title
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let subreddit = subscriptions[indexPath.row]
        let timelineVC = TimelineViewController(subredditName: subreddit.displayName)
        timelineVC.provider = Networking.newNetworking()
        timelineVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(timelineVC, animated: true)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Unsubscribe") {action in
            self.subscriptions.removeAtIndex(indexPath.row)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
        
        return [deleteAction]
    }

    func showBackgroundView() {
        if self.subscriptions.count == 0 { tableView.backgroundView = background }
    }
}


extension SubscriptionViewController {
    func mixTimelines() {

    }
}
