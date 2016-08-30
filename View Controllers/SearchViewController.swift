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

let kFetchMoreResultsNotification = "FetchMoreResultsNotification"
let kDisplaySearchHistoryNotification = "DisplaySearchHistoryNotification"

/**
 This multi-purpose tableview will handle thress kinds of content.
 */
enum TableContent {
    case .History
    case .Subreddit
    case .Link
}

class SearchViewController: UIViewController {

    let searchController = UISearchController(searchResultsController: nil)
    
    /**
     Holds the results for subreddits search
     */
    var subreddits = [Subreddit]()

    /**
     Holds the results for title search
     */
    var links = [Link]()
    
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
        tableView = UITableView(frame: CGRectMake(0, 20, view.frame.width, view.frame.height-20))
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        definesPresentationContext = true
        view.addSubview(tableView)
        tableView.registerNib(UINib(nibName: "SubredditCell", bundle: nil), forCellReuseIdentifier: "SubredditCell")

        setupUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.showHistory), name: kDisplaySearchHistoryNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            return .LightContent
        } else {
            return .Default
        }
    }
    
    func setupUI() {
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.tableView.tableFooterView = UIView()
        
        edgesForExtendedLayout = .None
        self.searchController.searchBar.searchBarStyle = .Minimal
        self.searchController.searchBar.sizeToFit()
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.scopeButtonTitles = ["Title", "Subreddit"]
        self.searchController.searchBar.selectedScopeButtonIndex = 0

        self.applyTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        self.searchController.view.removeFromSuperview()
        self.searchController.removeFromParentViewController()
    }

    func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            view.backgroundColor = FlatBlackDark()
            self.tableView.backgroundColor = FlatBlackDark()
            self.tableView.separatorColor = UIColor(colorLiteralRed: 0.11, green: 0.11, blue: 0.16, alpha: 1.0)
            self.tableView.indicatorStyle = .White
            self.searchController.searchBar.barTintColor = FlatBlackDark()
            self.searchController.searchBar.tintColor = FlatOrange()
            self.searchController.searchBar.backgroundColor = FlatBlackDark()
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).textColor = FlatOrange()
        } else {
            view.backgroundColor = UIColor.whiteColor()
            self.tableView.backgroundColor = UIColor(colorLiteralRed: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
            self.tableView.separatorColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.01, alpha: 1.0)
            self.tableView.indicatorStyle = .Default
            self.searchController.searchBar.barTintColor = FlatWhiteDark()
            self.searchController.searchBar.tintColor = FlatOrange()
            self.searchController.searchBar.backgroundColor = UIColor.whiteColor()
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).textColor = UIColor.blackColor()
        }
    }

    func showHistory() {
        
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let subreddit = self.subreddits[indexPath.row]
        let timelineVC = HomeViewController(subredditName: subreddit.displayName)
        timelineVC.hidesBottomBarWhenPushed = true
        timelineVC.isFromSearch = true
        timelineVC.subreddit = subreddit
        
        navigationController?.pushViewController(timelineVC, animated: true)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if  scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height - 350 {
            NSNotificationCenter.defaultCenter().postNotificationName("NeedTopicPrefetchNotification", object: nil)
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.subreddits.count == 0 {
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subreddits.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SubredditCell", forIndexPath: indexPath) as! SubredditCell
        let sub = self.subreddits[indexPath.row]
        cell.loadCell(sub)
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let addAction = UITableViewRowAction(style: .Default, title: "Subscribe") {action in
            tableView.setEditing(false, animated: true)
        }
        addAction.backgroundColor = FlatGreen()
        
        return [addAction]
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
                    self.subreddits = subs
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
                self.subreddits = subs
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }

            // Remember the searched text only on success.
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                let app = UIApplication.sharedApplication().delegate as! AppDelegate
                do {
                    try app.database.executeUpdate("INSERT INTO search_history(term, timestamp, user) values(?, ?, ?)", values: [text, NSDate.sqliteDate(), app.user])
                } catch let err as NSError {
                    print("failed: \(err.localizedDescription)")
                }
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.subreddits.removeAll()
        self.tableView.reloadData()
        self.searchController.active = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.subreddits.removeAll()
            self.tableView.reloadData()
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) {
        searchBar.showsScopeBar = true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) {
        searchBar.showsScopeBar = false
    }
}
