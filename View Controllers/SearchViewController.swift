//
//  SearchViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-31.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework

class SearchViewController: UIViewController {

    let searchController = UISearchController(searchResultsController: nil)
    
    var results = [Subreddit]()
    
    var tableView: UITableView!
    
    // Trigger a new search only after user pause for a while
    private var timer: NSTimer?
    
    // Record the text in search bar from lastest state
    private var prevText: String = ""
    
    /// Cache the searched results so we don't make redundant api calls
    private var cache = [String:AnyObject]()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        tableView = UITableView(frame: CGRectMake(0, 20, view.bounds.width, view.bounds.height - 20))
        tableView.delegate = self
        tableView.dataSource = self
        
        definesPresentationContext = true
        view.addSubview(tableView)
        tableView.registerNib(UINib(nibName: "SubredditCell", bundle: nil), forCellReuseIdentifier: "SubredditCell")
        setupUI()
    }
    
    func setupUI() {
        self.navigationItem.title = "Add Subreddits"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
        self.navigationController?.navigationBar.translucent = false

        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.tableView.tableFooterView = UIView()
        
        self.searchController.searchBar.searchBarStyle = .Minimal
        self.searchController.searchBar.tintColor = FlatOrange()
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let channel = self.results[indexPath.row]
        let timelineVC = HomeViewController(channel: channel.displayName)
        timelineVC.hidesBottomBarWhenPushed = true
        timelineVC.isFromSearch = true
        
        self.presentViewController(NavigationController(rootViewController: timelineVC), animated: true) {
            
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.results.count == 0 {
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SubredditCell", forIndexPath: indexPath) as! SubredditCell
        
        // Configure the cell...
        let sub = self.results[indexPath.row]
        
        cell.loadCell(sub)
        
        return cell
    }

}


extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if self.searchController.dimsBackgroundDuringPresentation {
            self.searchController.dimsBackgroundDuringPresentation = false
        }
        
        if let text = searchController.searchBar.text {
            if text.isEmpty { return }
            // only trigger new search if searched text changes
            if text != self.prevText {
                if let subs = self.cache[text] as? [Subreddit] {
                    self.results = subs
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                    
                    return
                }
                
                if let timer = self.timer {
                    timer.invalidate()
                }
                
                self.timer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: #selector(SearchViewController.triggerSearchWith(_:)), userInfo: text, repeats: false)
            }
        }
    }
    
    
    func triggerSearchWith(timer: NSTimer) {
        let subredditsResource = Resource(url: "/subreddits/search", method: .GET, parser: subredditsParser)
        let text = timer.userInfo as! String
        apiRequest(Config.ApiBaseURL, resource: subredditsResource, params: ["q" : text, "limit" : "45"]) { (subs) -> Void in
            NetworkActivityIndicator.decreaseActivityCount()
            
            if let subs = subs {
                self.results = subs
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
            
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.results.removeAll()
        self.tableView.reloadData()
        self.searchController.active = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.results.removeAll()
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    }
}