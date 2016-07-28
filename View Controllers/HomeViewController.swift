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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Front Page"
        self.navigationItem.leftBarButtonItem   = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: nil)
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
        
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        let rightBarButton = UIBarButtonItem(title: String.fontAwesomeIconWithName(.Tag), style: .Plain, target: self, action: #selector(HomeViewController.changeSubreddit))
        rightBarButton.setTitleTextAttributes(attributes, forState: .Normal)
        self.navigationItem.rightBarButtonItem  = rightBarButton
        
        self.automaticallyAdjustsScrollViewInsets = false
        
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
        
        dispatch_async(dispatch_get_main_queue()) {
            HUDManager.sharedInstance.showCentralActivityIndicator()
            self.topicController.reload()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self.topicController, selector: #selector(TopicController.prefetch), name: "NeedTopicPrefetchNotification", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self.topicController)
    }
    
    func setupUI() {
        
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
        }
    }
    
    func topicControllerDidFailedLoading(topicController: TopicController) {
        if self.topicTableViewController.refreshControl!.refreshing {
            self.topicTableViewController.refreshControl?.endRefreshing()
        }
        
        if HUDManager.sharedInstance.isShowing {
            HUDManager.sharedInstance.hideCentralActivityIndicator()
        }
        
        // Notify user of bad connection
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
            
            self.topicController.changeSubreddit(textField.text ?? "")
            HUDManager.sharedInstance.showCentralActivityIndicator()
            self.topicTableViewController.tableView.userInteractionEnabled = true
            dispatch_async(dispatch_get_main_queue()) {
                self.topicController.reload()
                // Scroll to top after reload
                self.topicTableViewController.tableView.setContentOffset(CGPointZero, animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
        }
    }
        
    
}