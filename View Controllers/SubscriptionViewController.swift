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
    
    // Show if no subscription 
    lazy var backgroundView: UIView = {
        return {
            let label = {
                $0.text = "You don't have any subscription yet."
                $0.font = UIFont(name: "Lato-Regular", size: 18)
                $0.textColor = UIColor.grayColor()
                $0.numberOfLines = 0
                $0.textAlignment = .Center
            }(UILabel())
            $0.addSubview(label)
            label.snp_makeConstraints { make in
                make.leading.equalTo($0).offset(25)
                make.trailing.equalTo($0).offset(-25)
                make.top.equalTo(UIScreen.mainScreen().bounds.height / 2 - 150)
            }

            return $0
        }(UIView())
    }()

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

        viewModel
            .updatedContents
            .subscribeOn(MainScheduler.instance)
            .map { _ in 
                return self.tableView
            }
            .doOnNext { tableView in 
                tableView.reloadData()
            }
            .subscribeNext { _ in }
            .addDisposableTo(disposeBag)

        viewModel
            .showBackground
            .subscribeOn(MainScheduler.instance)
            .filter(false)
            .subscribeNext { [weak self] _ in 
                self?.tableView.backgroundView = self?.backgroundView
            }
            .addDisposableTo(disposeBag)
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

// MARK: Sort Functionality
extension SubscriptionViewController {
    func sortItemTapped() {
        let alert = self.sortOrderAlertController()
        presentViewController(alert, animated: true, completion: nil)
    }

    func sortOrderAlertController() -> UIAlertController {
        let sortOrderController = UIAlertController(title: "Choose order of subscribed subreddits", message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction.Action("Cancel", style: .Cancel)
        sortOrderController.addAction(cancelAction)
        
        ["Alphabetical", "Popularity", "Favorite"].enumerate().map { (index, name) in 
            let mod = name + (self.selectedOrderIndex.value == index) ? "✓" : ""
            let option = UIAlertAction.Action(mod, style: .Default)
            option.rx_action = CocoaAction {
                self.selectedOrderIndex.value = index
                return Observable.empty()
            }
            sortOrderController.addAction(option)
        }
        
        return sortOrderController
    }
}

