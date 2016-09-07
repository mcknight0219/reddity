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
let kChangeSearchResultsContext = "ChangeSearchResultsContext"

/**
 This multi-purpose tableview will handle thress kinds of content.
 */
enum TableContent: String, CustomStringConvertible {
    case History = "History"
    case Subreddit = "Subreddit"
    case Link = "Link"
    
    var description: String {
        return self.rawValue
    }
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

    /**
     Holds the results for search history
     */
    var history = [String]()

    /**
     The current displaying content of `tableView`
     */
    var currentTableContent: TableContent = .History
    
    var tableView: UITableView!

    var scopeBar: UISegmentedControl!
    
    // Trigger a new search only after user pause for a while
    private var timer: NSTimer?
    
    // Record the text in search bar from lastest state
    private var prevText: String = ""
    
    /// Cache the searched results so we don't make redundant api calls
    private var cache = [String:AnyObject]()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
        tableView.delegate = self
        tableView.dataSource = self

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        headerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scopeBar = UISegmentedControl(items: ["Title", "Subreddit"])
        scopeBar.frame = CGRectMake(0, 0, headerView.frame.width - 120, headerView.frame.height - 13)
        scopeBar.center = headerView.center
        scopeBar.selectedSegmentIndex = 0
        scopeBar.addTarget(self, action: #selector(SearchViewController.scopeBarDidChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
        headerView.addSubview(scopeBar)
        scopeBar.clipsToBounds = true
        scopeBar.layer.cornerRadius = CGRectGetHeight(scopeBar.bounds) / 2
        scopeBar.layer.borderWidth = 1
        
        let wrapper = UIView(frame: headerView.bounds)
        wrapper.addSubview(headerView)
        
        let separatorView = UIView(frame: CGRectMake(0, headerView.frame.height-1, headerView.frame.width, 1))
        separatorView.backgroundColor = UIColor(white: 224/255, alpha: 1.0)
        headerView.addSubview(separatorView)
        
        tableView.tableHeaderView = wrapper
        
        view.addSubview(tableView)
        tableView.registerNib(UINib(nibName: "SubredditCell", bundle: nil), forCellReuseIdentifier: "SubredditCell")
        tableView.registerNib(UINib(nibName: "LinkCell", bundle: nil), forCellReuseIdentifier: "LinkCell")

        setupUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.onContextSwitch), name: kChangeSearchResultsContext, object: nil)

        NSNotificationCenter.defaultCenter().postNotificationName(kChangeSearchResultsContext, object: TableContent.History.rawValue)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupUI() {
        definesPresentationContext = true
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.tableView.tableFooterView = UIView()
        
        edgesForExtendedLayout = .None
        automaticallyAdjustsScrollViewInsets = false
        self.searchController.searchBar.searchBarStyle = .Minimal
        navigationItem.titleView = self.searchController.searchBar
        
        searchController.hidesNavigationBarDuringPresentation = false
    
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
            self.tableView.tableHeaderView?.backgroundColor = FlatBlackDark()
            self.tableView.separatorColor = UIColor(colorLiteralRed: 0.11, green: 0.11, blue: 0.16, alpha: 1.0)
            self.tableView.indicatorStyle = .White
            self.searchController.searchBar.barTintColor = FlatBlackDark()
            self.searchController.searchBar.tintColor = FlatBlueDark()
            self.searchController.searchBar.backgroundColor = FlatBlackDark()
            self.scopeBar.tintColor = FlatBlueDark()
            self.scopeBar.layer.borderColor = FlatBlueDark().CGColor
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).textColor = FlatOrange()
        } else {
            view.backgroundColor = UIColor.whiteColor()
            self.tableView.backgroundColor = UIColor.whiteColor()
            self.tableView.tableHeaderView?.backgroundColor = UIColor.whiteColor()
            self.tableView.separatorColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.01, alpha: 1.0)
            self.tableView.indicatorStyle = .Default
            self.searchController.searchBar.barTintColor = FlatWhiteDark()
            self.searchController.searchBar.tintColor = FlatOrange()
            self.searchController.searchBar.backgroundColor = UIColor.whiteColor()
            self.scopeBar.tintColor = FlatOrange()
            self.scopeBar.layer.borderColor = FlatOrange().CGColor
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).textColor = UIColor.blackColor()
        }
        
        for subView in searchController.searchBar.subviews {
            if let scopeBar = subView as? UISegmentedControl {
                scopeBar.backgroundColor = ThemeManager.defaultManager.currentTheme == "Dark" ? FlatBlackDark() : UIColor.whiteColor()
            }
        }
    }

    func scopeBarDidChange(scopeBar: UISegmentedControl) {
            NSNotificationCenter.defaultCenter().postNotificationName(kChangeSearchResultsContext, object: currentTableContent.rawValue)
    }

    func onContextSwitch(notification: NSNotification) {
        self.currentTableContent = TableContent(rawValue: notification.object as! String)!
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            self.history = []
            self.links = []
            self.subreddits = []
            
            switch self.currentTableContent {
            case .History:
                    let app = UIApplication.sharedApplication().delegate as! AppDelegate
                    let rs = try! app.database!.executeQuery("SELECT term FROM search_history WHERE user = ?", values: [app.user])
                    while rs.next() {
                        let term = rs.stringForColumn("term")    
                        self.history.append(term)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                break
            default:
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }   
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if currentTableContent == .History {
            return 44
        } else  {
            return 100
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if currentTableContent == .History {
            
        } else if currentTableContent == .Subreddit {
            let subreddit = self.subreddits[indexPath.row]
            let timelineVC = HomeViewController(subredditName: subreddit.displayName)
            timelineVC.hidesBottomBarWhenPushed = true
            timelineVC.isFromSearch = true
            timelineVC.subreddit = subreddit
            
            navigationController?.pushViewController(timelineVC, animated: true)
        } else {
            
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let headerView = self.tableView.tableHeaderView?.subviews[0]
        // Always keep scope bar at the top when pulling down.
        headerView?.transform = CGAffineTransformMakeTranslation(0, min(0, offsetY))
    }
}

extension SearchViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentTableContent {
        case .History:
            return self.history.count + 1
        case .Link:
            return self.links.count
        case .Subreddit:
            return self.subreddits.count
        }
    }
    
    /**
     TODO it feels clumsy to have three different types of cells in one functions.
     However, these three cells are so different that it's not intuitive to abstract them.
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if currentTableContent == .Subreddit {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("SubredditCell", forIndexPath: indexPath) as! SubredditCell
            let sub = self.subreddits[indexPath.row]
            cell.loadCell(sub)

            return cell

        } else if currentTableContent == .Link {
            var cell = self.tableView.dequeueReusableCellWithIdentifier("LinkCell")
            if cell == nil {
                cell = BaseTableViewCell(style: .Default, reuseIdentifier: "LinkCell")
            }

            let link = self.links[indexPath.row]
            cell!.imageView?.sd_setImageWithURL(link.url, placeholderImage: UIImage.imageFilledWithColor(FlatWhite()))
            cell!.textLabel?.text = link.title

            return cell!
        } else {
            var cell = self.tableView.dequeueReusableCellWithIdentifier("HistoryCell")
            if cell == nil {
                cell = BaseTableViewCell(style: .Default, reuseIdentifier: "HistoryCell")
            }
            if indexPath.row < self.history.count {
                cell!.textLabel?.text = self.history[indexPath.row]
            } else {
                cell!.textLabel?.text = "Clear recent search"
            }
            

            return cell!
        }
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if currentTableContent == .Subreddit {
            let addAction = UITableViewRowAction(style: .Default, title: "Subscribe") {action in
                tableView.setEditing(false, animated: true)
            }
            addAction.backgroundColor = FlatGreen()

            return [addAction]
        } 
        // No action needed for history and links
        return nil
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
        var resource: Resource<Any>
        if self.currentTableContent == .Subreddit {
            resource = Resource(url: "/subreddits/search", method: .GET, parser: subredditsParser)
        } else {
            resource =  Resource(url: "/search", method: .GET, parser: linkParser)
        }
        
        var text = timer.userInfo as! String
        if self.currentTableContent == .Link { text = "title:\(text)" }

        apiRequest(Config.ApiBaseURL, resource: resource, params: ["q" : text, "limit" : "45"]) { [unowned self] (subs) -> Void in
            NetworkActivityIndicator.decreaseActivityCount()
            
            if let subs = subs as? [Subreddit]{
                self.subreddits = subs
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }

            // Remember the searched text only on success.
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                let app = UIApplication.sharedApplication().delegate as! AppDelegate
                do {
                    try app.database!.executeUpdate("INSERT INTO search_history(term, timestamp, user) values(?, ?, ?)", values: [text, NSDate.sqliteDate(), app.user])
                } catch let err as NSError {
                    print("failed: \(err.localizedDescription)")
                }
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        //self.searchController.active = false
        // On cancel, show search history 
        //NSNotificationCenter.defaultCenter().postNotificationName(kChangeSearchResultsContext, object: TableContent.History.rawValue)
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

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        NSNotificationCenter.defaultCenter().postNotificationName(kChangeSearchResultsContext, object: TableContent.Subreddit.rawValue)
    
        return true
    }
}
