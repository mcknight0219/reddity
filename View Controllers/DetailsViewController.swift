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
import SnapKit

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
    
    var topView:  UIView!

    lazy var indicatorView: UIActivityIndicatorView = {
        
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            return UIActivityIndicatorView(activityIndicatorStyle: .White)
        } else {
            return UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        }
    }()
    
    lazy var topIndicatorView: UIActivityIndicatorView = {
       
        return UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        
    }()
    
    var layout: LayoutType!

    let subject: Link
    
    // The original comments tree
    var comments = [Comment]()

    // The comments that are actullay displayed in tableview.
    var commentsOSD = [Comment]()
    
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
                
        commentsVC = BaseTableViewController()
        commentsVC.tableView.frame = view.bounds
        commentsVC.tableView.delegate = self
        commentsVC.tableView.dataSource = self
        commentsVC.tableView.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        commentsVC.tableView.rowHeight = UITableViewAutomaticDimension
        commentsVC.tableView.estimatedRowHeight = 80
        commentsVC.tableView.tableFooterView = UIView()
        commentsVC.tableView.setContentOffset(CGPointZero, animated: false)
        commentsVC.tableView.cellLayoutMarginsFollowReadableWidth = false
        
        addChildViewController(commentsVC)
        view.addSubview(commentsVC.view)
        commentsVC.didMoveToParentViewController(self)
    
        
        topView = UIView(frame: CGRectMake(0, 0, view.bounds.width, 200))
        topView.backgroundColor = UIColor.clearColor()
        self.configTopView()
        commentsVC.tableView.tableHeaderView = topView

        // indicator for comments table 
        
        view.insertSubview(indicatorView, aboveSubview: commentsVC.view)
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()

        navigationItem.backBarButtonItem  = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        if self.layout != .Text {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: nil)
        } 

        
        let commentsResource = Resource(url: "/r/\(self.subject.subreddit)/comments/\(self.subject.id)", method: .GET, parser: commentsParser)
        apiRequest(Config.ApiBaseURL, resource: commentsResource, params: ["raw_json": "1"]) {[unowned self] comments in
            guard comments != nil else {
                print("Server returns zero comments")
                return
            }
            
            self.comments = comments!
            // Sort comments by popularity
            self.comments.sortInPlace { $0.score > $1.score }
            for i in 0..<self.comments.count {
                self.comments[i].replies.sortInPlace { $0.score > $1.score }
            }
            self.markCommentsVisibility()
            self.loadCommentsOSD()
                        
            dispatch_async(dispatch_get_main_queue()) {
                self.indicatorView.stopAnimating()
                self.indicatorView.removeFromSuperview()
                
                self.commentsVC.tableView.reloadData()
            }
        }
        
        self.applyTheme()
    }
    
    override func viewDidLayoutSubviews() {
        commentsVC.tableView.contentOffset = CGPointZero
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.translucent = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = nil
        
        NSNotificationCenter.defaultCenter().postNotificationName(kThemeManagerDidChangeThemeNotification, object: nil)
    }
    
    func applyTheme() {
        guard self.topView.subviews.count > 0 else { return }
        
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.view.backgroundColor = UIColor(colorLiteralRed: 32/255, green: 34/255, blue: 34/255, alpha: 1.0)
            self.topView.backgroundColor = UIColor(colorLiteralRed: 32/255, green: 34/255, blue: 34/255, alpha: 1.0)
        } else {
            self.view.backgroundColor = UIColor(colorLiteralRed: 32/255, green: 34/255, blue: 34/255, alpha: 1.0)
            self.topView.backgroundColor = UIColor.whiteColor()
        }
        
        
        if let label = self.topView.subviews[0] as? InsetLabel {
            
            if ThemeManager.defaultManager.currentTheme == "Dark" {
                label.backgroundColor = UIColor(colorLiteralRed: 32/255, green: 34/255, blue: 34/255, alpha: 1.0)
                label.textColor = UIColor.whiteColor()
            } else {
                label.backgroundColor = UIColor.whiteColor()
                label.textColor = UIColor.blackColor()
            }
        }
    }
    
    private func configTopView() {
        if self.layout == .Text {
            
            let quoteMark = UIImage.fontAwesomeIconWithName(.QuoteLeft, textColor: UIColor.whiteColor(), size: CGSize(width: 20, height: 20))
            let attachment = NSTextAttachment()
            attachment.image = quoteMark
          
            let attachmentString = NSAttributedString(attachment: attachment)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .Justified
            let title = NSMutableAttributedString(string: self.subject.title, attributes: [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 18)!, NSParagraphStyleAttributeName: paragraphStyle])
            
            title.insertAttributedString(attachmentString, atIndex: 0)
            
            let textLabel = InsetLabel()
            textLabel.numberOfLines = 0
            textLabel.textAlignment = .Left
            textLabel.attributedText = title
            
            self.topView.addSubview(textLabel)
            textLabel.snp_makeConstraints { make in
                make.left.right.top.bottom.equalTo(self.topView)
            }

        } else if self.layout == .External {

            let button = UIButton()
            button.setImage(UIImage.fontAwesomeIconWithName(.ExternalLink, textColor: FlatOrange(), size: CGSize(width: 20, height: 20)), forState: .Normal)
            
            let style = NSMutableParagraphStyle()
            style.alignment = .Center
            style.lineBreakMode = .ByCharWrapping
            
            let link = NSMutableAttributedString(string: " \(self.subject.url.host!)", attributes: [
                NSFontAttributeName: UIFont(name: "Lato-Bold", size: 18)!,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                NSParagraphStyleAttributeName: style,
                NSForegroundColorAttributeName: FlatOrange()
                ])

            button.setAttributedTitle(link, forState: .Normal)

            button.addTarget(self, action: #selector(DetailsViewController.openExternalLink), forControlEvents: UIControlEvents.TouchUpInside)
            
            button.sizeToFit()

            self.topView.addSubview(button)
            
            button.center = self.topView.center
        } else {
            
            let imageView = UIImageView()
            imageView.contentMode = .ScaleAspectFill
            imageView.clipsToBounds = true
            
            self.topView.addSubview(self.topIndicatorView)
            self.topIndicatorView.center = self.topView.center
            self.topIndicatorView.startAnimating()
            
            imageView.sd_setImageWithURL(self.subject.url, placeholderImage: nil, options: [], progress: nil, completed: { (_, _, _, _)  in

                self.topIndicatorView.stopAnimating()
                
                self.topIndicatorView.removeFromSuperview()
            
            })

            self.topView.addSubview(imageView)

            imageView.snp_makeConstraints { make in
                
                make.left.right.top.bottom.equalTo(self.topView)
            
            }

            let tap = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.handleImageTap(_:)))
            
            self.topView.addGestureRecognizer(tap)
        }

    }

    @objc private func openExternalLink() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        ac.addAction(cancelAction)

        let openAction = UIAlertAction(title: "Open in Safari", style: .Default) { [unowned self] (action) in
            
            let safariViewController = SFSafariViewController(URL: self.subject.url)
            
            self.presentViewController(safariViewController, animated: true, completion: nil)
        
        }
        
        ac.addAction(openAction)

        presentViewController(ac, animated: true) {}
    }

    @objc private func handleImageTap(sender: UITapGestureRecognizer) {
        
        let imageDetailVC = ImageDetailViewController(URL: self.subject.url)
        
        imageDetailVC.modalTransitionStyle = .CrossDissolve
        imageDetailVC.modalPresentationStyle = .FullScreen
        
        self.navigationController?.presentViewController(imageDetailVC, animated: true, completion: nil)
    }
}


extension DetailsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let comment = self.commentsOSD[indexPath.row]
        if comment.isPlaceholder {
            var parent = self.commentsOSD[indexPath.row-1].parent
            commentsOSD.removeAtIndex(indexPath.row)
            
            self.commentsVC.tableView.beginUpdates()
            self.commentsVC.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
            self.commentsVC.tableView.endUpdates()

            for i in (0..<parent!.replies.count).reverse() {
                
            }
            
        } 
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 {
            self.navigationController?.navigationBar.hidden = true
        } else {
            self.navigationController?.navigationBar.hidden = false
        }
    }
}

// MARK: - Table view data source

extension DetailsViewController : UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
 
        return 1
    
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = commentsVC.tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        cell.configCellWith(&self.commentsOSD[indexPath.row])
        
        return cell
    
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.commentsOSD.count 
    
    }
}

extension DetailsViewController {
        
    /**
     Extract comments which are active into OSD array.

     @discussion we use commentsOSD to display in the table
     */
    private func loadCommentsOSD() {
        self.commentsOSD.removeAll()

        for comment in self.comments {
            if comment.isShow {
                self.commentsOSD.append(comment)
                self.loadRepliesOSD(comment.replies)
            }        
        }
    }

    private func loadRepliesOSD(replies: [Comment]) {
        guard replies.count > 0 else { return }

        var hasHidden = false
        var level: Int?
        for var reply in replies {
            if reply.isShow { 
                self.commentsOSD.append(reply) 
                self.loadRepliesOSD(reply.replies)
            } else {
                level = reply.level
                hasHidden = true
            }
        }

        if hasHidden {
            self.commentsOSD.append(makePlaceholder(level!))
        }
    }

    /**
     @discussion The default display status is always `false` on start
     */
    private func markCommentsVisibility() {
        let showAll = self.comments.reduce(0) { $0 + $1.totalReplies() } > 20
        for i in 0..<self.comments.count {
            if showAll { self.comments[i].markIsShow { _ in true } }
            else {
                self.comments[i].markIsShow { $0.score >= 5 } 
            }
        }    
    }
} 

