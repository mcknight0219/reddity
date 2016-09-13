//
//  DetailsViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-15
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SafariServices
import FontAwesome_swift

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
    var comments = [Comment]()
    
    init(aSubject: Link) {

        self.subject = aSubject
        if subject.type()       == .News { layout = .External }
        else if subject.type()  == .Text { layout = .Text }
        else                             { layout = .Media }
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aCoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsVC = UITableViewController()
        addChildViewController(commentsVC)
  
        view.addSubview(commentsVC.view)
        commentsVC.didMoveToParentViewController(self)
       
        indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        commentsVC.tableView.addSubview(indicatorView)
        indicatorView.hidesWhenStopped = true
        indicatorView.center = commentsVC.tableView.center
        self.setupUI()

        indicatorView.startAnimating()
        let commentsResource = Resource(url: "/r/\(self.subject.subreddit)/comments/\(self.subject.id)", method: .GET, parser: commentsParser)
        apiRequest(Config.ApiBaseURL, resource: commentsResource, params: ["raw_json": "1"]) {[weak self] comments in

            self?.comments = comments!
            dispatch_async(dispatch_get_main_queue()) {
                self?.commentsVC.tableView.reloadData()
                self?.indicatorView.stopAnimating()
            }
        }
    }

    private func setupUI() {
        navigationItem.title = self.subject.title
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 17)!]
        navigationItem.backBarButtonItem  = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        if self.layout != .Text {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(DetailsViewController.openExternalLink))
            navigationItem.rightBarButtonItem.setTitleTextAttributes([NSFontAttributeName: UIFont.fontAwesomeOfSize(20)], forState: .Normal)
            navigationItem.rightBarButtonItem.title = String.fontAwesomeIconWithName(.ExternalLink)
        }
    }

    private func commentsCount(comments: [Comment]) -> Int {
        return comments.reduce(0) { $0 + $1.totalReplies() }
    }

    private func openExternalLink() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        ac.addAction(cancelAction)

        let openAction = UIAlertAction(title: "Open in Safari", style: .Default) { [unowned self] (action) in
            let url = self.subject.url
            let safariViewController = SFSafariViewController(URL: url)
            presentViewController(safariViewController, animated: true, completion: nil)
        }
        ac.addAction(openAction)

        presentViewController(ac, animated: true) {}
    }
}

// MARK: - Table view data source

extension DetailsViewController : UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, heigthForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
