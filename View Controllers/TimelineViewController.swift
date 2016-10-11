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

class TimelineViewController: BaseViewController {

    var topicTableViewController: TopicTableViewController!
    
    var topicDataSource: TopicDataSource!
    
    var topicController: TopicController!
    
    /**
     The subreddit name.

     @discussion The empty channel means 
     */
    var subredditName: String = ""

    var subreddit: Subreddit?
    
    var isFromSearch: Bool = false
    
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
        
        topicDataSource = TopicDataSource()
        topicDataSource.cellIdentifier = "Cell"
        
        topicController = TopicController()
        topicController.delegate = self
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
        
        NSNotificationCenter.defaultCenter().addObserver(topicController, selector: #selector(TopicController.prefetch), name: "NeedTopicPrefetchNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(topicController, selector: #selector(TopicController.changeSubreddit), name: "NeedLoadSubreddit", object: nil)
        
        HUDManager.sharedInstance.showCentralActivityIndicator()
        // Assign to subreddit will trigger loading of data
        topicController.subreddit = subredditName
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

