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
    var inset = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
    
    init(_ rect: UIEdgeInsets? = nil) {
        super.init(frame: CGRectZero)
        if rect != nil && rect != inset {
            inset = rect!
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
    
    var topViewHeight: CGFloat = 200
    
    lazy var lastContentOffset: CGFloat = {
        return self.commentsVC.tableView.contentOffset.y
    }()
    
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

        commentsVC = {
            $0.tableView.frame = view.bounds
            $0.tableView.delegate = self
            $0.tableView.dataSource = self
            $0.tableView.rowHeight = UITableViewAutomaticDimension
            $0.tableView.estimatedRowHeight = 40
            $0.tableView.tableFooterView = UIView()
            $0.edgesForExtendedLayout = .All
            $0.extendedLayoutIncludesOpaqueBars = false
            //$0.automaticallyAdjustsScrollViewInsets = true
            $0.tableView.cellLayoutMarginsFollowReadableWidth = false
            
            $0.tableView.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
            $0.tableView.registerNib(UINib(nibName: "LoadmoreCell", bundle: nil), forCellReuseIdentifier: "LoadmoreCell")
            
            return $0
        }(BaseTableViewController())
        
        addChildViewController(commentsVC)
        view.addSubview(commentsVC.view)
        commentsVC.didMoveToParentViewController(self)
    
        if layout == .External {
            topViewHeight = 120 // titleLabel: 44 + button: 50 + gap: 6
        } else if layout == .Text {
            topViewHeight = 150 // titleLabel: 44 + text: 80 + gap:6
        } else {
            topViewHeight = 240
        }
        
        topView = UIView(frame: CGRectMake(0, 0, view.bounds.width, topViewHeight))
        topView.backgroundColor = UIColor.clearColor()
        self.configTopView()
        commentsVC.tableView.tableHeaderView = topView

        // indicator for comments table 
        
        view.insertSubview(indicatorView, aboveSubview: commentsVC.view)
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()

        let navTitle: UILabel = {
            $0.text = subject.subreddit
            $0.font = UIFont(name: "Lato-Regular", size: 20)
            $0.textAlignment = .Center
            $0.backgroundColor = UIColor.clearColor()
            $0.numberOfLines = 2
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.8
            $0.textColor = UIColor(colorLiteralRed: 79/255, green: 90/255, blue: 119/255, alpha: 1.0)
            return $0
        }(UILabel(frame: CGRectMake(0, 0, 200, 40)))
        
        self.navigationItem.titleView = navTitle
        if self.layout != .Text {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: nil)
        } 

        
        let commentsResource = Resource(url: "/r/\(self.subject.subreddit)/comments/\(self.subject.id)", method: .GET, parser: commentsParser)
        apiRequest(Config.ApiBaseURL, resource: commentsResource, params: ["raw_json": "1"]) { comments in
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
    
    func applyTheme() {
        guard self.topView.subviews.count > 0 else { return }
        
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.view.backgroundColor = UIColor(colorLiteralRed: 33/255, green: 34/255, blue: 35/255, alpha: 1.0)
            self.topView.backgroundColor = UIColor(colorLiteralRed: 33/255, green: 34/255, blue: 45/255, alpha: 1.0)
        } else {
            self.view.backgroundColor = UIColor(colorLiteralRed: 32/255, green: 34/255, blue: 34/255, alpha: 1.0)
            self.topView.backgroundColor = UIColor(colorLiteralRed: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
        }
        
        
        for subview in self.topView.subviews {
            if let v = subview as? InsetLabel {
                if ThemeManager.defaultManager.currentTheme == "Dark" {
                    v.backgroundColor = UIColor(colorLiteralRed: 28/255, green: 28/255, blue: 37/255, alpha: 1.0)
                    v.textColor = UIColor(colorLiteralRed: 79/255, green: 90/255, blue: 119/255, alpha: 1.0)
                } else {
                    v.backgroundColor = UIColor.whiteColor()
                    v.textColor = UIColor.blackColor()
                }
            }
            
                if ThemeManager.defaultManager.currentTheme == "Dark" {
                    subview.backgroundColor = UIColor(colorLiteralRed: 28/255, green: 28/255, blue: 37/255, alpha: 1.0)
                } else {
                    subview.backgroundColor = UIColor.whiteColor()
                }
            
        }
       
    }
    
    private func configTopView() {
        let titleLabel: InsetLabel = {
            $0.text = subject.title
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.8
            $0.numberOfLines = 2
            $0.font = UIFont(name: "Lato-Bold", size: 18)
            $0.textAlignment = .Justified
            return $0
        }(InsetLabel())
        
        
        let separator = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 15))
        separator.backgroundColor = UIColor.clearColor()
        
        if self.layout == .Text {
            let quoteMark = UIImage.fontAwesomeIconWithName(.QuoteLeft, textColor: UIColor.whiteColor(), size: CGSize(width: 20, height: 20))
            let attachment = NSTextAttachment()
            attachment.image = quoteMark
          
            let attachmentString = NSAttributedString(attachment: attachment)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .Justified
            let title = NSMutableAttributedString(string: self.subject.title, attributes: [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 18)!, NSParagraphStyleAttributeName: paragraphStyle])
            
            title.insertAttributedString(attachmentString, atIndex: 0)
            
            let textLabel: InsetLabel = {
                $0.numberOfLines = 0
                $0.textAlignment = .Left
                $0.text = "Self text ..."
                return $0
            }(InsetLabel())
            
            topView.addSubview(titleLabel)
            titleLabel.snp_makeConstraints { make in
                make.top.left.equalTo(self.topView).offset(5)
                make.right.equalTo(self.topView).offset(-5)
                make.height.equalTo(64)
            }
            
            self.topView.addSubview(textLabel)
            textLabel.snp_makeConstraints { make in
                make.left.equalTo(self.topView).offset(5)
                make.right.equalTo(self.topView).offset(-5)
                make.top.equalTo(titleLabel.snp_bottom)
                make.bottom.equalTo(self.topView).offset(-15)
            }

        } else if self.layout == .External {
            
            let button = UIButton()
            button.setImage(UIImage.fontAwesomeIconWithName(.ExternalLink, textColor: UIColor(colorLiteralRed: 79/255, green: 90/255, blue: 119/255, alpha: 1.0), size: CGSize(width: 20, height: 20)), forState: .Normal)
            
            let style = NSMutableParagraphStyle()
            style.alignment = .Center
            style.lineBreakMode = .ByCharWrapping
            
            let link = NSMutableAttributedString(string: " \(self.subject.url.host!)", attributes: [
                NSFontAttributeName: UIFont(name: "Lato-Bold", size: 16)!,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                NSParagraphStyleAttributeName: style,
                NSForegroundColorAttributeName: UIColor(colorLiteralRed: 79/255, green: 90/255, blue: 119/255, alpha: 1.0)
                ])

            button.setAttributedTitle(link, forState: .Normal)
            button.addTarget(self, action: #selector(DetailsViewController.openExternalLink), forControlEvents: UIControlEvents.TouchUpInside)
            button.sizeToFit()
            
            topView.addSubview(titleLabel)
            titleLabel.snp_makeConstraints { make in
                make.top.left.equalTo(self.topView).offset(5)
                make.right.equalTo(self.topView).offset(-5)
                make.height.equalTo(64)
            }
            
            let linkView = UIView()
            topView.addSubview(linkView)
            linkView.snp_makeConstraints { make in
                make.top.equalTo(titleLabel.snp_bottom)
                make.right.equalTo(topView).offset(-5)
                make.left.equalTo(topView).offset(5)
                make.bottom.equalTo(topView).offset(-15)
            }
            
            linkView.addSubview(button)
            button.snp_makeConstraints { make in
                make.center.equalTo(linkView)
            }
            
        } else {
            
            let imageView = UIImageView()
            imageView.contentMode = .ScaleAspectFill
            imageView.clipsToBounds = true
            self.topView.addSubview(imageView)
            imageView.snp_makeConstraints { make in
                make.left.top.equalTo(self.topView).offset(5)
                make.right.equalTo(self.topView).offset(-5)
                make.bottom.equalTo(self.topView).offset(-79)
            }
            
            self.topView.addSubview(self.topIndicatorView)
            self.topIndicatorView.center = self.topView.center
            self.topIndicatorView.startAnimating()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.handleImageTap(_:)))
            self.topView.addGestureRecognizer(tap)
            
            let placeholder = UIImage.imageFilledWithColor(ThemeManager.defaultManager.currentTheme == "Dark" ? UIColor(colorLiteralRed: 28/255, green: 28/255, blue: 37/255, alpha: 1.0) : UIColor(colorLiteralRed: 0.94, green: 0.94, blue: 0.96, alpha: 1.0))
            imageView.sd_setImageWithURL(self.subject.url, placeholderImage: placeholder, options: [], progress: nil, completed: { (_, _, _, _)  in
                
                self.topIndicatorView.stopAnimating()
                
                self.topIndicatorView.removeFromSuperview()
                
            })
            
            topView.addSubview(titleLabel)
            titleLabel.snp_makeConstraints { make in
                make.left.equalTo(self.topView).offset(5)
                make.right.equalTo(self.topView).offset(-5)
                make.top.equalTo(imageView.snp_bottom)
                make.bottom.equalTo(self.topView).offset(-15)
            }
        }

        self.topView.addSubview(separator)
        separator.snp_makeConstraints { make in
            make.bottom.equalTo(self.topView)
            make.centerY.equalTo(self.topView)
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
        var comment = self.commentsOSD[indexPath.row]
        if comment.isPlaceholder {
            var r = indexPath.row - 1
            guard r >= 0 else { return }
            while r >= 0 {
                if self.commentsOSD[r].level != comment.level { break }
                else { r -= 1 }
            }
            
            let parent = self.commentsOSD[r]
            
            commentsOSD.removeAtIndex(indexPath.row)
            
            let vc = self.commentsVC
            vc.tableView.beginUpdates()
            vc.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            vc.tableView.endUpdates()
            
            var row = indexPath.row
            vc.tableView.beginUpdates()
            (parent.replies.filter { !$0.isShow }).forEach { c in
                let descendants = c.flatten()
                descendants.forEach {
                    commentsOSD.insert($0, atIndex: row)
                    vc.tableView.insertRowsAtIndexPaths([NSIndexPath.init(forItem: row, inSection: 0)], withRowAnimation: .Bottom)
                    row += 1
                }
            }
            
            vc.tableView.endUpdates()
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let startOffsetY:CGFloat!
        let endOffsetY: CGFloat!
        switch self.layout! {
        case .Media:
            startOffsetY = 180
            endOffsetY = 280
            break
        default:
            startOffsetY = 5
            endOffsetY = 80
        }
        
        let totalHeight = endOffsetY - startOffsetY
        
        if offsetY > startOffsetY && offsetY < endOffsetY {
            if lastContentOffset < offsetY {    // Scroll down
                if offsetY - startOffsetY < totalHeight / 2 {
                    UIView.animateWithDuration(0.2) {
                        self.navigationItem.titleView!.alpha = 1.0 - (offsetY - startOffsetY) / (totalHeight / 2)
                    }
                    
                } else {
                    
                    (self.navigationItem.titleView as? UILabel)?.text = subject.title
                    UIView.animateWithDuration(0.2) {
                        self.navigationItem.titleView!.alpha = (offsetY - startOffsetY - totalHeight / 2) / (totalHeight / 2)
                    }
                }
            } else {    // Scroll up
                if endOffsetY - offsetY < totalHeight / 2 {
                    UIView.animateWithDuration(0.2) {
                        self.navigationItem.titleView!.alpha = 1.0 - (endOffsetY - offsetY) / (totalHeight / 2)
                    }
                } else {
                    (self.navigationItem.titleView as? UILabel)?.text = subject.subreddit
                    
                    UIView.animateWithDuration(0.2) {
                        self.navigationItem.titleView!.alpha = (endOffsetY - offsetY - totalHeight / 2) / (totalHeight / 2)
                    }
                }
            }
        }
        
        self.lastContentOffset = offsetY
    }
}

// MARK: - Table view data source

extension DetailsViewController : UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.commentsOSD[indexPath.row].isPlaceholder {
            let cell = commentsVC.tableView.dequeueReusableCellWithIdentifier("LoadmoreCell", forIndexPath: indexPath) as! LoadmoreCell
            cell.configWith(&self.commentsOSD[indexPath.row])
            return cell
        } else {
            let cell = commentsVC.tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
            cell.configCellWith(&self.commentsOSD[indexPath.row])
            return cell
        }
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
        for i in 0..<self.comments.count {
            self.comments[i].markIsShow { $0.score >= 3 }
        }    
    }
} 

