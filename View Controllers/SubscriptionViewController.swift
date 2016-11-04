//
//  SubscriptionViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-02
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import Action
import RxSwift

class SubscriptionViewController: BaseTableViewController {
    var provider: Networking!
    
    private var selectedOrderIndex = Variable<Int>(0)
    var viewModel: SubscriptionViewModelType {
        return SubscriptionViewModel(provider: self.provider, selectedOrder: self.selectedOrderIndex.asObservable())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideFooter()
        
        navigationItem.title = "Subscription"
        navigationController?.navigationBar.titleTextAttributes![NSFontAttributeName] = UIFont(name: "Lato-Regular", size: 20)!
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .Plain, target: self, action: #selector(SubscriptionViewController.sortItemTapped))

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfSubscriptions
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionCell")
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "SubscriptionCell")
        }

        let sub = self.viewModel.subredditModelAtIndexPath(indexPath)
        cell!.textLabel?.text = sub.title
        
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let subreddit = self.viewModel.subredditModelAtIndexPath(indexPath)
        
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
            
        }
        
        return [deleteAction]
    }
}

extension SubscriptionViewController {
    func sortItemTapped() {
        presentViewController(self.sortOrderAlertController, animated: true, completion: nil)
    }
}

extension SubscriptionViewController {
    var sortOrderAlertController: UIAlertController {
        let sortOrderController = UIAlertController(title: "Choose order of subscribed subreddits", message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction.Action("Cancel", style: .Cancel)
        sortOrderController.addAction(cancelAction)
        
        let sortByAlpha = UIAlertAction.Action("Alphabetical", style: .Default)
        sortOrderController.addAction(sortByAlpha)
        
        let sortByPopularity = UIAlertAction.Action("Popularity", style: .Default)
        sortOrderController.addAction(sortByPopularity)
        
        let sortByFavorite = UIAlertAction.Action("Favorite", style: .Default)
        sortOrderController.addAction(sortByFavorite)
        
        sortOrderController
        
        return sortOrderController
    }
}

