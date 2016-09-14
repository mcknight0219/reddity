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
let kTriggerSearchWithTerm = "TriggerSearchWithTerm"
let kLoadMoreSearchResults = "LoadMoreSearchResults"

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

class SearchViewController: BaseViewController {

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
     Holds the scope information for search history item
     */
    var historyScope = [Int]()

    /**
     The current displaying content of `tableView`
     */
    var currentTableContent: TableContent = .History
    
    var tableView: UITableView!

    var scopeBar: UISegmentedControl!

    /**
     * @discussion We put it here because it needs change according to theme
     */
    var separatorView: UIView!
    
    // Trigger a new search only after user pause for a while
    private var timer: NSTimer?
    
    // Record the text in search bar from lastest state
    private var prevText: String = ""
    
    // Cache the searched results so we don't make redundant api calls
    private var cache = [String:AnyObject]()

    // The `after` flag in search api call for title search
    private var afterTitle: String = ""

    // The `after` flag in search api call for subreddit search
    private var afterSubreddit: String = ""
    
    // For placeholder view when history is empty
    lazy var backgroundView: UIView = {
        let background = UIView()
        
        let image = UIImageView(image: UIImage.fontAwesomeIconWithName(.Search, textColor: FlatWhiteDark(), size: CGSizeMake(50, 50)))        
        background.addSubview(image)
        image.center = CGPoint(x: UIScreen.mainScreen().bounds.width / 2, y: UIScreen.mainScreen().bounds.height / 2 - 150)

        let label = UILabel()
        label.text = "You can search subreddits name and title"
        label.font = UIFont(name: "Lato-Regular", size: 18)!
        label.textColor = FlatWhiteDark()
        label.numberOfLines = 0
        label.textAlignment = .Center
        background.addSubview(label)
        label.snp_makeConstraints { make in
            make.leading.equalTo(background).offset(30)
            make.trailing.equalTo(background).offset(-30)
            make.top.equalTo(image.snp_bottom).offset(5)
        }

        return background
    }()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .None
        automaticallyAdjustsScrollViewInsets = false
        tableView = UITableView(frame: CGRectMake(0, 0, view.frame.width, view.frame.height))
        tableView.autoresizingMask = [.FlexibleHeight]
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
        
        self.separatorView = UIView(frame: CGRectMake(0, headerView.frame.height-1, headerView.frame.width, 1))
        headerView.addSubview(self.separatorView)
        
        tableView.tableHeaderView = wrapper
        view.addSubview(tableView)
        ["SubredditCell", "LinkCell"].forEach { name in
            tableView.registerNib(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.onContextSwitch), name: kChangeSearchResultsContext, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.loadMoreContent), name: kLoadMoreSearchResults, object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(kChangeSearchResultsContext, object: TableContent.History.rawValue)

        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let nav = navigationController?.navigationBar
        nav?.translucent = false
        let img = UIImage()
        nav?.shadowImage = img
        nav?.setBackgroundImage(img, forBarMetrics: .Default)
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
        searchController.dimsBackgroundDuringPresentation = false
    
        self.applyTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        self.searchController.view.removeFromSuperview()
        self.searchController.removeFromParentViewController()
        if let timer = self.timer { timer.invalidate() }
    }

    func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            view.backgroundColor = FlatBlackDark()
            navigationController?.navigationBar.barTintColor = FlatBlack()
            self.tableView.backgroundColor = FlatBlackDark()
            self.tableView.tableHeaderView?.backgroundColor = ClearColor()
            self.tableView.separatorColor = UIColor(colorLiteralRed: 0.11, green: 0.11, blue: 0.16, alpha: 1.0)
            self.tableView.indicatorStyle = .White
            self.searchController.searchBar.barTintColor = FlatBlue()
            self.searchController.searchBar.tintColor = FlatBlue()
            self.searchController.searchBar.backgroundColor = FlatBlack()
            self.scopeBar.tintColor = FlatBlue()
            self.scopeBar.layer.borderColor = FlatBlue().CGColor
            self.separatorView.backgroundColor = UIColor(colorLiteralRed: 0.11, green: 0.11, blue: 0.16, alpha: 1.0)
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).defaultTextAttributes = [NSForegroundColorAttributeName: FlatBlue()]
        } else {
            view.backgroundColor = UIColor.whiteColor()
            self.tableView.backgroundColor = UIColor.whiteColor()
            navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
            self.tableView.tableHeaderView?.backgroundColor = ClearColor()
            self.tableView.separatorColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.01, alpha: 1.0)
            self.tableView.indicatorStyle = .Default
            self.searchController.searchBar.barTintColor = FlatOrange()
            self.searchController.searchBar.tintColor = FlatOrange()
            self.searchController.searchBar.backgroundColor = UIColor.whiteColor()
            self.scopeBar.tintColor = FlatOrange()
            self.scopeBar.layer.borderColor = FlatOrange().CGColor
            self.separatorView.backgroundColor = UIColor(white: 224/255, alpha: 1.0)
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).defaultTextAttributes = [NSForegroundColorAttributeName: FlatBlack()]
        }
        
        for subView in searchController.searchBar.subviews {
            if let scopeBar = subView as? UISegmentedControl {
                scopeBar.backgroundColor = ThemeManager.defaultManager.currentTheme == "Dark" ? FlatBlackDark() : UIColor.whiteColor()
            }
        }
    }

    func scopeBarDidChange(scopeBar: UISegmentedControl) {
        guard currentTableContent != .History else {
            return
        }
        
        if scopeBar.selectedSegmentIndex == 0 {
            self.currentTableContent = .Link
        } else {
            self.currentTableContent = .Subreddit
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kChangeSearchResultsContext, object: currentTableContent.rawValue)
    }

    
    func onContextSwitch(notification: NSNotification) {
        self.currentTableContent = TableContent(rawValue: notification.object as! String)!
        self.tableView.backgroundView = nil
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            self.history.removeAll()
            self.links.removeAll()
            self.subreddits.removeAll()
            
            switch self.currentTableContent {
            case .History:
                    let app = UIApplication.sharedApplication().delegate as! AppDelegate
                    let rs = try! app.database!.executeQuery("SELECT term, scope FROM search_history WHERE user = ?", values: [app.user])
                    while rs.next() {
                        let term = rs.stringForColumn("term")    
                        self.history.append(term)
                    }

                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        if self.history.count == 0 { 
                            self.tableView.backgroundView = self.backgroundView
                            return
                        }
                    }
                break
            default:
                // If the search field is not empty, the context switch will trigger search
                // of the term within new scope
                if let text = self.searchController.searchBar.text {
                    if !text.isEmpty {
                        self.emulateTriggerSearchWith(text)
                    }
                }
                
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
        let row = indexPath.row

        if currentTableContent == .History {
            if row == self.history.count {
                // Delete all history for this user
                let app = UIApplication.sharedApplication().delegate as! AppDelegate
                do {
                    try app.database!.executeUpdate("DELETE FROM search_history WHERE user = ?", values: [app.user])
                } catch let error as NSError {
                    print("failed: \(error.localizedDescription)")
                }

                NSNotificationCenter.defaultCenter().postNotificationName(kChangeSearchResultsContext, object: TableContent.History.rawValue)
                return  
            }
            
            self.emulateTriggerSearchWith(self.history[row])
        } else if currentTableContent == .Subreddit {
            let subreddit = self.subreddits[row]
            let timelineVC = HomeViewController(subredditName: subreddit.displayName)
            timelineVC.hidesBottomBarWhenPushed = true
            timelineVC.isFromSearch = true
            timelineVC.subreddit = subreddit
            
            navigationController?.pushViewController(timelineVC, animated: true)
        } else {
           let link = self.links[row] 
           let detailVC = DetailsViewController(aSubject: link)
           detailVC.hidesBottomBarWhenPushed = true

           navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let headerView = self.tableView.tableHeaderView?.subviews[0]
        // Always keep scope bar at the top when pulling down.
        headerView?.transform = CGAffineTransformMakeTranslation(0, min(0, offsetY))

        if offsetY > scrollView.contentSize.height - scrollView.frame.size.height {
            NSNotificationCenter.defaultCenter().postNotificationName(kLoadMoreSearchResults, object: nil)
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentTableContent {
        case .History:
            // The plus one is for "Clear the recent search" item
            return self.history.count == 0 ? 0 : self.history.count + 1
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
        let row = indexPath.row
        if currentTableContent == .Subreddit {
            let cell = tableView.dequeueReusableCellWithIdentifier("SubredditCell", forIndexPath: indexPath) as! SubredditCell
            let sub = self.subreddits[row]
            cell.loadCell(sub)

            return cell

        } else if currentTableContent == .Link {
            var cell = tableView.dequeueReusableCellWithIdentifier("LinkCell")
            if cell == nil {
                cell = BaseTableViewCell(style: .Default, reuseIdentifier: "LinkCell")
            }

            let link = self.links[row]
            cell!.imageView?.sd_setImageWithURL(link.url, placeholderImage: UIImage.imageFilledWithColor(FlatWhite()))
            cell!.textLabel?.text = link.title

            return cell!
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell")
            if cell == nil {
                cell = BaseTableViewCell(style: .Default, reuseIdentifier: "HistoryCell")
            }
            if row < self.history.count {
                cell!.textLabel?.text = self.history[row]
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

// MARK: - UISearchResultUpdating

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
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
    
    /**
     @discussion Underlying we rely on timer-based mechanisim to perform searching.
     This function will re-schdule a dummy timer.   
     */
    func emulateTriggerSearchWith(text: String) {
        if let timer = self.timer { timer.invalidate() }
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(SearchViewController.triggerSearchWith(_:)), userInfo: text, repeats: false)
    }

    func triggerSearchWith(timer: NSTimer) {
        guard self.currentTableContent != .History else {
            return
        } 

        let text = timer.userInfo as! String
        if scopeBar.selectedSegmentIndex == 0 {
            self.currentTableContent = .Link
            searchTitleAndUpdate(text)
        } else {
            self.currentTableContent = .Subreddit
            searchSubredditAndUpdate(text)
        }
    }

    func loadMoreContent() {
        guard self.currentTableContent != TableContent.History else {
            return
        }
        
        let text = self.searchController.searchBar.text
        (self.currentTableContent == .Subreddit) ? searchSubredditAndUpdate(text!, after: afterSubreddit) : searchTitleAndUpdate(text!, after: afterTitle)
    }

    private func searchTitleAndUpdate(title: String, after: String = "") {
        let resource =  Resource(url: "/search", method: .GET, parser: linkParser)
        let text = "title:\(title)"

        apiRequest(Config.ApiBaseURL, resource: resource, params: ["q": text, "limit": "100", "after": after]) { [unowned self] (links) -> Void in
            NetworkActivityIndicator.decreaseActivityCount()

            if let links = links {
                self.links.appendContentsOf(links)
                self.afterTitle = self.links.last!.name

                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func searchSubredditAndUpdate(subreddit: String, after: String = "") {
        let resource = Resource(url: "/subreddits/search", method: .GET, parser: subredditsParser)
        
        apiRequest(Config.ApiBaseURL, resource: resource, params: ["q" : subreddit, "limit" : "45", after: after]) { [unowned self] (subs) -> Void in
            NetworkActivityIndicator.decreaseActivityCount()

            if let subs = subs {
                self.subreddits.appendContentsOf(subs)
                self.afterSubreddit = self.subreddits.last!.name

                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }

            // Remember the searched text only on successi and the term is more than a word.
            if subreddit.characters.count > 3 {
                self.recordSeachHistory(subreddit)
            }

        }
    }

    private func recordSeachHistory(term: String) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            let app = UIApplication.sharedApplication().delegate as! AppDelegate
            do {
                // update the timestamp of history term
                let rs = try app.database!.executeQuery("SELECT * FROM search_history WHERE term = ? AND user = ?", values: [term, app.user])
                if rs.next() {
                    try app.database!.executeUpdate("UPDATE search_history SET timestamp = ? WHERE term = ? AND user = ?", values: [ NSDate.sqliteDate(), term, app.user])
                    return
                }

                try app.database!.executeUpdate("INSERT INTO search_history(term, timestamp, scope, user) values(?, ?, ?, ?)", values: [term, NSDate.sqliteDate(), self.scopeBar.selectedSegmentIndex, app.user])
            } catch let err as NSError {
                print("failed: \(err.localizedDescription)")
            }
        }

    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        //self.searchController.active = false
        // On cancel, show search history 
        NSNotificationCenter.defaultCenter().postNotificationName(kChangeSearchResultsContext, object: TableContent.History.rawValue)
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
