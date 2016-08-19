//
//  ViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
import FontAwesome_swift

class HomeViewController: UIViewController {

    var topicTableViewController: TopicTableViewController!
    
    var topicDataSource: TopicDataSource!
    
    var topicController: TopicController!
    
    var channel: String = ""
    
    var isFromSearch: Bool = false
    
    init(channel: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.channel = channel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        self.topicDataSource = TopicDataSource()
        self.topicDataSource.cellIdentifier = "Cell"
        
        self.topicController = TopicController()
        self.topicController.delegate = self
        
        self.topicTableViewController = TopicTableViewController()
        
        self.addChildViewController(self.topicTableViewController)
        
        //self.topicTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.topicTableViewController.view.frame = self.view.bounds
        
        self.view.addSubview(self.topicTableViewController.view)
        
        self.topicTableViewController.didMoveToParentViewController(self)
        
        self.topicTableViewController.dataSource = self.topicDataSource

        self.topicTableViewController.tableView.registerNib(UINib(nibName: "NewsCell", bundle: nil),  forCellReuseIdentifier: "NewsCell")
        self.topicTableViewController.tableView.registerNib(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
        self.topicTableViewController.tableView.registerNib(UINib(nibName: "TextCell", bundle: nil),  forCellReuseIdentifier: "TextCell")
        self.topicTableViewController.refreshControl?.addTarget(self.topicController, action: #selector(TopicController.reload), forControlEvents: .ValueChanged)
        self.topicTableViewController.tableView.tableFooterView = UIView()
        
        NSNotificationCenter.defaultCenter().addObserver(self.topicController, selector: #selector(TopicController.prefetch), name: "NeedTopicPrefetchNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self.topicController, selector: #selector(TopicController.changeSubreddit), name: "NeedLoadSubreddit", object: nil)
        
        
        HUDManager.sharedInstance.showCentralActivityIndicator()
        //NSNotificationCenter.defaultCenter().postNotificationName("NeedLoadSubreddit", object: self.channel)
        
        // Trigger table reload by setting subreddit of topicController
        self.topicController.subreddit = self.channel
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self.topicController)
    }
    
    func setupUI() {
        self.navigationItem.title = self.channel.isEmpty ? "Front Page" : self.channel
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
    
        if isFromSearch {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(HomeViewController.backToSearch))
        } else {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        }
        
        /*
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        let rightBarButton = UIBarButtonItem(title: String.fontAwesomeIconWithName(.Tag), style: .Plain, target: self, action: #selector(HomeViewController.changeSubreddit))
        rightBarButton.setTitleTextAttributes(attributes, forState: .Normal)
        self.navigationItem.rightBarButtonItem  = rightBarButton
        */
        
        self.automaticallyAdjustsScrollViewInsets = true
    }
    
    func backToSearch() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: TopicController delegate

extension HomeViewController: TopicControllerDelegate {
    
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
            /*
            UIView.setAnimationsEnabled(true)
            self.topicTableViewController.tableView.beginUpdates()
            if let visibleIndexs = self.topicTableViewController.tableView.indexPathsForVisibleRows {
                self.topicTableViewController.tableView.reloadRowsAtIndexPaths(visibleIndexs, withRowAnimation: .None)
            }
            self.topicTableViewController.tableView.endUpdates()
            UIView.setAnimationsEnabled(false)
             */
        }
    }
    
    func topicControllerDidFailedLoading(topicController: TopicController) {
        if self.topicTableViewController.refreshControl!.refreshing {
            self.topicTableViewController.refreshControl?.endRefreshing()
        }
        
        if HUDManager.sharedInstance.isShowing {
            HUDManager.sharedInstance.hideCentralActivityIndicator()
        }
        
        // Alert user bad response
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

extension HomeViewController {
    func changeSubreddit() {
        
        let alertController = UIAlertController(title: "Change Subreddit", message: "", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = self.topicController.subreddit
        }
        
        
        let okAction = UIAlertAction(title: "Go", style: .Default) { (_) in
            let textField = alertController.textFields![0] as UITextField
            
            HUDManager.sharedInstance.showCentralActivityIndicator()
            NSNotificationCenter.defaultCenter().postNotificationName("NeedLoadSubreddit", object: textField.text)
            self.topicTableViewController.tableView.userInteractionEnabled = true
            dispatch_async(dispatch_get_main_queue()) {
                self.topicController.reload()
                // Scroll to top after reload
                self.topicTableViewController.tableView.setContentOffset(CGPointMake(0, 0), animated: true)
                
                if textField.text!.isEmpty {
                    self.navigationItem.title = "Front Page"
                } else {
                    self.navigationItem.title = textField.text
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        alertController.view.tintColor = FlatOrange()
        self.presentViewController(alertController, animated: true) {
        }
    }
        
    
}
