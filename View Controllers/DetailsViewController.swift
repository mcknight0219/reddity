//
//  DetailsViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-15
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SafariServices
import ChameleonFramework
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
    
    var textLabel: InsetLabel!
    
    var textView:  UITextView!

    lazy var indicatorView: UIActivityIndicatorView = {
        
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            return UIActivityIndicatorView(activityIndicatorStyle: .White)
        } else {
            return UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        }
    }()
    
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
        
        self.setupHeaderView()
        
        let offset: CGFloat = (self.layout == .Text) ? 120 : 0
        
        
        commentsVC = BaseTableViewController()
        commentsVC.tableView.frame = CGRectMake(0, offset, view.bounds.width, view.bounds.height - offset)
        commentsVC.tableView.delegate = self
        commentsVC.tableView.dataSource = self
        commentsVC.tableView.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        commentsVC.tableView.rowHeight = UITableViewAutomaticDimension
        commentsVC.tableView.estimatedRowHeight = 80
        
        addChildViewController(commentsVC)
        view.addSubview(commentsVC.view)
        commentsVC.didMoveToParentViewController(self)
       
    
        commentsVC.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, view.bounds.width, 34))
        commentsVC.tableView.tableHeaderView?.addSubview(indicatorView)
        indicatorView.center = commentsVC.tableView.tableHeaderView!.center
        commentsVC.tableView.tableFooterView = UIView()
        indicatorView.hidesWhenStopped = true
    
        navigationItem.backBarButtonItem  = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        if self.layout != .Text {
            navigationItem.title = self.subject.title
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(DetailsViewController.openExternalLink))
            navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSFontAttributeName: UIFont.fontAwesomeOfSize(20)], forState: .Normal)
            navigationItem.rightBarButtonItem!.title = String.fontAwesomeIconWithName(.ExternalLink)
        } else {
            navigationItem.title = ""
        }

        indicatorView.startAnimating()
        let commentsResource = Resource(url: "/r/\(self.subject.subreddit)/comments/\(self.subject.id)", method: .GET, parser: commentsParser)
        apiRequest(Config.ApiBaseURL, resource: commentsResource, params: ["raw_json": "1"]) {[weak self] comments in
            self?.comments = comments!
            dispatch_async(dispatch_get_main_queue()) {
                self?.indicatorView.stopAnimating()
                self?.commentsVC.tableView.tableHeaderView = nil
                self?.commentsVC.tableView.reloadData()
            }
        }
        
        self.applyTheme()
    }
    
    func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.textLabel?.backgroundColor = UIColor.blackColor()
            self.textLabel?.textColor = UIColor.whiteColor()
        } else {
            self.textLabel?.backgroundColor = UIColor.whiteColor()
            self.textLabel?.textColor = UIColor.blackColor()
        }
    }
    
    private func setupHeaderView() {
        if self.layout == .Text {
            
            let quoteMark = UIImage.fontAwesomeIconWithName(.QuoteLeft, textColor: UIColor.whiteColor(), size: CGSize(width: 20, height: 20))
            let attachment = NSTextAttachment()
            attachment.image = quoteMark
            
            let attachmentString = NSAttributedString(attachment: attachment)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .Justified
            let title = NSMutableAttributedString(string: self.subject.title, attributes: [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 18)!, NSParagraphStyleAttributeName: paragraphStyle])
            
            title.insertAttributedString(attachmentString, atIndex: 0)
            
            self.textLabel = InsetLabel(frame: CGRectMake(0, 0 , view.bounds.width, 120))
            self.textLabel.numberOfLines = 0
            self.textLabel.textAlignment = .Left
            self.textLabel.attributedText = title
            
            view.addSubview(self.textLabel)
        } else if self.layout == .External {

            let externalMark = UIImage.fontAwesomeIconWithName(.ExternalLink, textColor: FlatOrange(), size: CGSize(width: 17, height: 17))
            let attachment = NSTextAttachment()
            attachment.image = externalMark
            
            let attachmentString = NSAttributedString(attachment: attachment)
            
            
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
        cell.loadComment(comments[indexPath.row])
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
}
