//
//  DetailsViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-15
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
import FontAwesome_swift
import SnapKit

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

class DetailsViewController: UIViewController {
    
    var commentsVC: UITableViewController!
    
    lazy var indicatorView: UIActivityIndicatorView = {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            return UIActivityIndicatorView(activityIndicatorStyle: .White)
        } else {
            return UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        }
    }()
    
    var layout: LayoutType!

    let subject: Link
    
    // The original comments tree
    var comments = [Comment]()

    // The comments that are actullay displayed in tableview.
    var commentsOSD = [Comment]()
    
    lazy var lastContentOffset: CGFloat = {
        return self.commentsVC.tableView.contentOffset.y
    }()
    
    init(aSubject: Link) {
        subject = aSubject
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
    
        // indicator for comments table 
        
        view.insertSubview(indicatorView, aboveSubview: commentsVC.view)
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()

        let navTitle: UILabel = {
            $0.text = subject.title
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

