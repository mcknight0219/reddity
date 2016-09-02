//
//  DetailsViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-15
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit


enum LayoutType {
    case Media
    case Text
    case External
}

/**
 Implements the detail view. There are 3 types of layouts: Image, Text, and External link.
 All three layouts have the same comments view. 

 */
class DetailsViewController: UIViewController {
    
    var commentsVC: UITableViewController!
    
    var imageContainer: UIView!

    var indicatorView: UIActivityIndicatorView!
    
    var layout: LayoutType!

    let subject: Link
    var comments: [Comment]
    
    init(aSubject: Link) {
        super.init(nibName: nil, bundle: nil)

        self.subject = aSubject
        if subject.type()       == .News { layout = .External }
        else if subject.type()  == .Text { layout = .Text }
        else                             { layout = .Media }
    }

    required init?(coder aCoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()

        
        commentsVC = UITableViewController()
        addChildViewController(commentsVC)
        commentsVC.view.frame = CGRectMake(0, w, w, h - w * 0.7)
        view.addSubview(commentsVC.view)
        commentsVC.didMoveToParentViewController(self)
        commentsVC.tableView.dataSource = comments
        
        indicatorView = UIActivityInidcatorView(activityIndicatorStyle: .Gray)
        commentsVC.tableView.addSubview(indicatorView)
        indicatorView.hidesWhenStopped = true
        indicatorView.center = commentsVC.tableView.center
        self.setupUI()

        indicator.startAnimating()
        let commentsResource = Resource(url: "/r/\(self.subject.subreddit)/comments/\(self.subject.id)", method: .GET, parser: commentsParser)
        apiRequest(Config.ApiBaseURL, resource: linksResource, params: ["raw_json": "1"]) {[weak self] comments in

            self?.comments = comments
            dispatch_async(dispatch_get_main_queue()) {
                self?.commentsVC.tableView.reloadData()
                self?.indicatorView.stopAnimating()
            }
        }
    }

    private func setupUI() {
        navigationItem.title = self.subject.title
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 17)!]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        commentsVC.automaticallyAdjustScrollViewInsects = false

        if layout == .External {
            navigationItem.rightBarButtonItem = UIBarButtonItem()
        }
    }

    private func commentsCount(comments: [Comment]) -> Int {
        return comments.reduce(0) { $0 + $1.totalReplies() }
    }
}

// MARK: - Table view data source

extension CommentsViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, heigthForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
