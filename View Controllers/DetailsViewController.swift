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


class InsetLabel: UILabel {
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
}

/**
 Implements the detail view. There are 3 types of layouts: Image, Text, and External link.
 All three layouts have the same comments view. 

 */
class DetailsViewController: UIViewController {
    
    var commentsVC: UITableViewController!
    
    var imageContainer: UIView!
    
    var textView: InsetLabel!

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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailsViewController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    required init?(coder aCoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.layout == .Text {
            self.textView = InsetLabel(frame: CGRectMake(0, 0 , view.bounds.width, 120))
            self.textView.textAlignment = .Left
            self.textView.numberOfLines = 0
            self.textView.text = self.subject.title
            self.textView.font = UIFont(name: "Lato-Regular", size: 18)

            view.addSubview(self.textView)
        }
        
        let offset: CGFloat = (self.layout == .Text) ? 120 : 0
        
        
        commentsVC = BaseTableViewController()
        commentsVC.view.frame = CGRectMake(0, offset, view.bounds.width, view.bounds.height - offset)
        commentsVC.tableView.delegate = self
        commentsVC.tableView.dataSource = self
        addChildViewController(commentsVC)
        commentsVC.tableView.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        commentsVC.tableView.rowHeight = UITableViewAutomaticDimension
        commentsVC.tableView.estimatedRowHeight = 80
        
        view.addSubview(commentsVC.view)
        commentsVC.didMoveToParentViewController(self)
       
        indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        commentsVC.tableView.addSubview(indicatorView)
        commentsVC.tableView.tableFooterView = UIView()
        indicatorView.hidesWhenStopped = true
        indicatorView.center = CGPointMake(view.center.x, view.center.y - 35)
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
        
        self.applyTheme()
    }
    
    func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.textView?.backgroundColor = UIColor.blackColor()
            self.textView?.textColor = UIColor.whiteColor()
        } else {
            self.textView?.backgroundColor = UIColor.whiteColor()
            self.textView?.textColor = UIColor.blackColor()
        }
    }

    private func setupUI() {
        navigationItem.backBarButtonItem  = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        if self.layout != .Text {
            navigationItem.title = self.subject.title
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(DetailsViewController.openExternalLink))
            navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont.fontAwesomeOfSize(20)], forState: .Normal)
            navigationItem.rightBarButtonItem!.title = String.fontAwesomeIconWithName(.ExternalLink)
        } else {
            navigationItem.title = ""
        }
    }

    private func commentsCount(comments: [Comment]) -> Int {
        return comments.reduce(0) { $0 + $1.totalReplies() }
    }

    @objc private func openExternalLink() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        ac.addAction(cancelAction)

        let openAction = UIAlertAction(title: "Open in Safari", style: .Default) { [unowned self] (action) in
            let url = self.subject.url
            let safariViewController = SFSafariViewController(URL: url)
            self.presentViewController(safariViewController, animated: true, completion: nil)
        }
        ac.addAction(openAction)

        presentViewController(ac, animated: true) {}
    }
}


extension DetailsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

// MARK: - Table view data source

extension DetailsViewController : UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = commentsVC.tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        cell.loadComment(3, text: comments[indexPath.row].text)
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
}
