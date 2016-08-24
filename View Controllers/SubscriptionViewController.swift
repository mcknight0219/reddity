//
//  SubscriptionViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-02
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

class SubscriptionViewController: UITableViewController {

    var subscriptions = [Subreddit]()

    var background: UIView?
    
    override func viewDidLoad() {
        navigationItem.title = "Subscription"
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
        
        let footer = UIView()
        footer.backgroundColor = FlatWhite()
        
        tableView.backgroundColor = FlatWhite()
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetZero
        tableView.tableFooterView = footer

        let background = UIView()
        let label = UILabel()
        label.text = "You don't have any subscription yet. Add some now !"
        label.font = UIFont(name: "Lato-Regular", size: 17)!
        label.numberOfLines = 0
        background.addSubview(label)
        label.snp_makeConstraints { make in
            make.trailing.leading.equalTo(10)
            make.top.equalTo(UIScreen.mainScreen().bounds.height / 2 - 100)
        }

        Preference.valuesForKey("subscriptions") { subscriptions in
            if let subscriptions = subscriptions as? [Subreddit] {
                subscriptions = subscriptions
                dispatch_async(dispatch_get_main_queue()) { 
                    self.subscriptions.count > 0 {
                        tableView.backgroundView = background
                    }
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

    override func tableView(tableView: UITableView, heightForRowAtIndex indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Subscriptions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionCell")
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "SubscriptionCell")    
        }

        let sub = self.subscriptions[indexPath.row]
        cell.textLabel.text = sub.title
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let subreddit = subscriptions[indexPath.row]
        let timelineVC = HomeViewController(subredditName: subreddit.displayName)
        timelineVC.hidesBottomBarWhenPushed = true
        timelineVC.subreddit = subreddit

        presentViewController(timelineVC, animated: true, completion: nil)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var deleteAction = UITableViewRowAction(style: .Default, title: "Unsubscribe") {action in
            subscriptions.remove(at: indexPath.row)
            Preference.setValueForKey(key: "subscriptions", value: subscriptions) {
                NSNotificationCenter.defaultCenter().postNotificationName("PreferenceChanged", object: "subscriptions")
            }
        }

        return [deleteAction]
    }

    func showBackgroundView() {
        if self.subscriptions.count == 0 { self.backgroundView = self.background }
    }
}
