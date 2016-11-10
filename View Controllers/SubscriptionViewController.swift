//
//  SubscriptionViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-02
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
import Action
import RxSwift

class SubscriptionViewController: BaseTableViewController {
 
    let _tapOnBackground = UITapGestureRecognizer()
    lazy var backgroundView: UIView = {
        return {
            let label: UILabel = {
                $0.text = "You don't have any subscription yet."
                $0.font = UIFont(name: "Lato-Regular", size: 18)
                $0.textColor = UIColor.grayColor()
                $0.numberOfLines = 0
                $0.textAlignment = .Center
                
                return $0
            }(UILabel())
            $0.addSubview(label)
            
            let this = $0
            label.snp_makeConstraints { make in
                make.leading.equalTo(this).offset(25)
                make.trailing.equalTo(this).offset(-25)
                make.top.equalTo(UIScreen.mainScreen().bounds.height / 2 - 150)
            }
            
            $0.addGestureRecognizer(self._tapOnBackground)

            return $0
        }(UIView())
    }()
    
    lazy var subtitleView: UILabel = {
        return {
            $0.backgroundColor = UIColor.clearColor()
            $0.font = UIFont(name: "Lato-Regular", size: 14)
            $0.textAlignment = .Center
            $0.textColor = UIColor.darkGrayColor()
            
            return $0
        }(UILabel(frame: CGRectMake(0, 24, 200, 44-24)))
    }()
    
    lazy var titleView: UILabel = {
        return {
            $0.backgroundColor = UIColor.clearColor()
            $0.font = UIFont(name: "Lato-Bold", size: 20)
            $0.textAlignment = .Center
            $0.textColor = UIColor.darkGrayColor()
            $0.text = "Subscription"

            return $0
        }(UILabel(frame: CGRectMake(0, 2, 200, 24)))
    }()

    var provider: Networking!
    
    private var selectedOrderIndex = Variable<Int>(0)
    lazy var viewModel: SubscriptionViewModelType = {
        return SubscriptionViewModel(provider: self.provider, selectedOrder: self.selectedOrderIndex.asObservable())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        hideFooter()
        
        let navTitleView =  UIView(frame: CGRectMake(0, 0, 200, 44))
        navTitleView.backgroundColor = UIColor.clearColor()
        navTitleView.autoresizesSubviews = true
        navTitleView.addSubview(self.titleView)
        navTitleView.addSubview(subtitleView)
        navTitleView.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleRightMargin, .FlexibleLeftMargin]
        navigationItem.titleView = navTitleView
        
        let sortButton = UIBarButtonItem(title: String.fontAwesomeIconWithName(.Reorder), style: .Plain, target: self, action: #selector(SubscriptionViewController.sortItemTapped))
        sortButton.setTitleTextAttributes([NSFontAttributeName: UIFont.fontAwesomeOfSize(24)], forState: .Normal)
        navigationItem.leftBarButtonItem = sortButton
        
        viewModel
            .updatedContents
            .subscribeOn(MainScheduler.instance)
            .map { n in
                return self.tableView
            }
            .doOnNext { tableView in
                tableView.reloadData()
            }
            .subscribeNext { _ in
                self.subtitleView.text = "(\(self.viewModel.numberOfSubscriptions))"
            }
            .addDisposableTo(disposeBag)

        viewModel
            .showBackground
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] show in
                if show {
                    self?.tableView.backgroundView = self?.backgroundView
                } else {
                    self?.tableView.backgroundView = nil
                }
            }
            .addDisposableTo(disposeBag)

        self.refreshControl
            .rx_controlEvent(.ValueChanged)
            .flatMap { reachabilityManager.reach }
            .subscribeNext {[weak self] on in
                if on {
                    self?.viewModel.reload()
                } else {
                    self?.refresControl.endRefreshing()
                }
            }
            .addDisposableTo(disposeBag)

        viewModel
            .showRefresh
            .asObservable()
            .subscribeNext {[weak self] show in
                if !show {
                    self?.refreshControl.endRefreshing()
                }
            }
            .addDisposableTo(disposeBag)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfSubscriptions
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionCell")
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "SubscriptionCell")
        }

        let sub = self.viewModel.subredditModelAtIndexPath(indexPath)
        cell!.textLabel?.text = sub.displayName
        cell!.detailTextLabel?.text = "\(sub.subscribers)"
        cell!.accessoryType = .DetailButton
        
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
            self.viewModel.unsubscribe(indexPath)
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
        
        _ = ["Alphabetical", "Popularity", "Favorite"].enumerate().map { (index, name) in
            var mod = name
            if self.selectedOrderIndex.value == index {
                mod = mod + "✓"
            }
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

extension SubscriptionViewController {
    override func applyTheme() {
        let theme = TableViewTheme()
        titleView.textColor = theme?.titleTextColor
    }
}

