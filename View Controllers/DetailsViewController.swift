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

class DetailsViewController: BaseViewController {
    
    var commentsVC: UITableViewController!
    
    lazy var indicatorView: UIActivityIndicatorView = {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            return UIActivityIndicatorView(activityIndicatorStyle: .White)
        } else {
            return UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        }
    }()
    
    lazy var subtitleView: UILabel = {
        return {
            $0.backgroundColor = UIColor.clearColor()
            $0.font = UIFont(name: "Lato-Regular", size: 14)
            $0.textAlignment = .Center
            $0.textColor = UIColor.darkGrayColor()
            
            return $0
        }(UILabel(frame: CGRectMake(0, 24, 200, 44-24)))
    }()
    
    lazy var titleView: UILabel = {
        return {
            $0.backgroundColor = UIColor.clearColor()
            $0.font = UIFont(name: "Lato-Bold", size: 18)
            $0.textAlignment = .Center
            $0.textColor = UIColor.darkGrayColor()
            $0.numberOfLines = 1
            
            return $0
        }(UILabel(frame: CGRectMake(0, 2, 200, 24)))
    }()
    
    lazy var footerView: UILabel = {
        return {
            $0.backgroundColor = CellTheme()?.backgroundColor
            $0.textAlignment = .Center
            $0.font = UIFont.fontAwesomeOfSize(16)
            $0.textColor = UIColor.darkGrayColor()
            $0.text = String.fontAwesomeIconWithName(.CircleO)
            
            return $0
        }(UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44)))
    }()

    let subject: Link
    
    // The original comments tree
    var comments = [Comment]()

    // The comments that are actullay displayed in tableview.
    var commentsOSD = [Comment]()
    
    var viewModel: CommentViewModelType!
    init(aSubject: Link, provider: Networking) {
        subject = aSubject
        viewModel = CommentViewModel(aLink: aSubject, provider: provider)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(viewModel: LinkViewModel, provider: Networking) {
        self.init(aSubject: viewModel.link, provider: provider)
    }

    required init?(coder aCoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup
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
        indicatorView.center = CGPointMake(view.bounds.width / 2, 13)
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()

        // Setup navigation bar
        titleView.text = subject.title
        subtitleView.text = "(\(subject.numberOfComments))"
        let navTitleView: UIView = {
            $0.backgroundColor = UIColor.clearColor()
            $0.autoresizesSubviews = true
            $0.addSubview(self.titleView)
            $0.addSubview(self.subtitleView)
            $0.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleRightMargin, .FlexibleLeftMargin]
            
            return $0
        }(UIView(frame: CGRectMake(0, 0, 200, 44)))
        navigationItem.titleView = navTitleView
        
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
                self.commentsVC.tableView.tableFooterView = self.footerView
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

