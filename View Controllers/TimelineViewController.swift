//
//  TimelineViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
import FontAwesome_swift
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}


class TimelineViewController: BaseViewController {

    var topicTableViewController: TopicTableViewController!
    var topicDataSource: TopicDataSource!
    
    var subredditName: String = ""
    var isFromSearch: Bool = false
    
    var provider: Networking!
    lazy var viewModel: TimelineViewModelType = {
        let nextPageTrigger =  self.topicTableViewController.tableView.rx_contentOffset
            .flatMap { _ in
                self.topicTableViewController.tableView.isNearBottomEdge()
                    ? Observable.just(())
                    : Observable.empty()
        }
        
        let reloadTrigger = self.topicTableViewController.refreshControl?.rx_controlEvent(.ValueChanged)

        return TimelineViewModel(subreddit: self.subredditName, provider: self.provider, loadNextPageTrigger: nextPageTrigger, reloadTrigger: reloadTrigger!.asObservable())
    }()
    
    init(subredditName: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.subredditName = subredditName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        topicTableViewController = {
            $0.view.frame = view.bounds
            $0.dataSource = topicDataSource
            $0.tableView.registerNib(UINib(nibName: "NewsCell", bundle: nil),  forCellReuseIdentifier: "NewsCell")
            $0.tableView.registerNib(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
            $0.tableView.registerNib(UINib(nibName: "TextCell", bundle: nil),  forCellReuseIdentifier: "TextCell")
            $0.refreshControl?.addTarget(topicController, action: #selector(TopicController.reload), forControlEvents: .
            ValueChanged)
            $0.tableView.tableFooterView = UIView()
            return $0
        }(TopicTableViewController())

        addChildViewController(topicTableViewController)
        view.addSubview(topicTableViewController.view)
        topicTableViewController.didMoveToParentViewController(self)
        
        
        // Map showSpinner to HUD status
        viewModel
            .showSpinner
            .subscribeNext { show in
                if show {
                    HUDManager.sharedInstance.showCentralActivityIndicator()
                } else {
                    HUDManager.sharedInstance.hideCentralActivityIndicator()
                }
            }
            .addDisposableTo(disposeBag)
        
    }
    
    func setupUI() {
        navigationItem.title = subredditName.isEmpty ? "Front Page" : subredditName
        navigationController?.navigationBar.titleTextAttributes![NSFontAttributeName] = UIFont(name: "Lato-Regular", size: 20)!
    
        if !isFromSearch {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        }
        
        automaticallyAdjustsScrollViewInsets = true
    }
    
    func backToSearch() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: TopicController delegate

extension TimelineViewController: TopicControllerDelegate {
    
    func topicControllerDidFinishLoading(topicController: TopicController) {
        if self.topicTableViewController.refreshControl!.refreshing {
            self.topicTableViewController.refreshControl?.endRefreshing()
        }
        
        if HUDManager.sharedInstance.isShowing {
            HUDManager.sharedInstance.hideCentralActivityIndicator()
        }
        
        self.topicDataSource.topics = self.topicController.topics
        dispatch_async(dispatch_get_main_queue()) {
            self.topicTableViewController.tableView.reloadData()
        }
    }
    
    func topicControllerDidFailedLoading(topicController: TopicController) {
        if self.topicTableViewController.refreshControl!.refreshing {
            self.topicTableViewController.refreshControl?.endRefreshing()
        }
        
        if HUDManager.sharedInstance.isShowing {
            HUDManager.sharedInstance.hideCentralActivityIndicator()
        }
        
        let badLoadingAlert = UIAlertController(title: "Server Error", message: "Reddit returns malform response", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        badLoadingAlert.addAction(okAction)
        badLoadingAlert.view.tintColor = FlatOrange()
        self.presentViewController(badLoadingAlert, animated: true, completion: nil)
    }
    
    func topicControllerNoNetworkConnection() {
        if self.topicTableViewController.refreshControl!.refreshing {
            self.topicTableViewController.refreshControl?.endRefreshing()
        }
        
        if HUDManager.sharedInstance.isShowing {
            HUDManager.sharedInstance.hideCentralActivityIndicator()
        }
        
        let label = UILabel()
        label.text = "No Internet conneciton"
        dispatch_async(dispatch_get_main_queue()) {
            self.topicTableViewController.tableView.tableHeaderView = label
        }
    }
}

