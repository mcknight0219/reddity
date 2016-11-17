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
import RxSwift

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


class CommentsTableViewController: BaseTableViewController {
    
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
    
    private var viewModel: CommentViewModelType
    private var parent: Comment?
    private var tableHeader: UIView?
    
    var reuseBag = DisposeBag()
    
    init(viewModel: CommentViewModelType, parentComment: Comment?, tableHeaderView: UIView?) {
        self.viewModel = viewModel
        self.parent = parentComment
        self.tableHeader = tableHeaderView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: life cycle
    
    override func viewDidLoad() {
        
        tableView.frame = UIScreen.mainScreen().bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
       
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        tableView.tableFooterView = self.footerView
        
        edgesForExtendedLayout = .All
        extendedLayoutIncludesOpaqueBars = false

        viewModel
            .updatedContents
            .subscribeNext { _ in
                self.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
        
        viewModel.showSpinner
            .subscribeNext {[weak self] show in
                if !show {
                    self?.tableView.tableFooterView = self?.footerView
                } else {
                    self?.tableView.tableFooterView = UIView()
                }
            }
            .addDisposableTo(disposeBag)
    }
}

extension CommentsTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let m = viewModel.commentAtIndexPath(indexPath, parent)
        guard m != nil else {
            return
        }
        let actionSheet = UIAlertController(title: "", message: "Reply to @\(m!.user)", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction.Action("Cancel", style: .Cancel)
        actionSheet.addAction(cancelAction)
        
        let replyAction = UIAlertAction.Action("Reply", style: .Default)
        actionSheet.addAction(replyAction)
        
        let downVoteAction = UIAlertAction.Action("Downvote", style: .Default)
        actionSheet.addAction(downVoteAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - Table view data source

extension CommentsTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        let comment = viewModel.commentAtIndexPath(indexPath, self.parent)
        cell.configCellWith(comment!)

        cell.expandRepliesPressed
            .subscribeNext { [weak self]  _ in
                if let ct = self {
                    let vc = CommentsTableViewController(viewModel: ct.viewModel, parentComment: comment, tableHeaderView: nil)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .addDisposableTo(disposeBag)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.parent?.replies.count ?? self.viewModel.numberOfComments
    }
}


class DetailsViewController: BaseViewController {
    
    var commentsVC: CommentsTableViewController!
    
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
            $0.font = UIFont(name: "Lato-Regular", size: 12)
            $0.textAlignment = .Center
            $0.textColor = UIColor.darkGrayColor()
            
            return $0
        }(UILabel(frame: CGRectMake(0, 24, 160, 44-24)))
    }()
    
    lazy var titleView: UILabel = {
        return {
            $0.backgroundColor = UIColor.clearColor()
            $0.font = UIFont(name: "Lato-Bold", size: 16)
            $0.textAlignment = .Center
            $0.textColor = UIColor.darkGrayColor()
            $0.numberOfLines = 1
            
            return $0
        }(UILabel(frame: CGRectMake(0, 2, 160, 24)))
    }()

    lazy var selfTextView: UIView? = {
        guard case .SelfText = self.subject.selfType else {
            return nil
        }
        
        let selfTextLabel: UILabel = {
            $0.backgroundColor = UIColor.lightGrayColor()
            $0.textAlignment = .Natural
            $0.font = UIFont.systemFontOfSize(16)
            $0.textColor = UIColor.blackColor()
            $0.text = self.subject.selfType.associatedValue ?? ""
            
            return $0
        }(UILabel())
        
        let view: UIView = {
            $0.addSubview(selfTextLabel)
            return $0
        }(UIView())
        
        selfTextLabel.snp_makeConstraints { make in
            make.edges.equalTo(view).inset(UIEdgeInsetsMake(20, 20, 20, 20))
        }
        
        return view
    }()

    
    var comments = [Comment]()
    let subject: Link
    lazy var viewModel: CommentViewModelType = {
        return CommentViewModel(aLink: self.subject, provider: self.provider)
    }()

    var provider: Networking!
    init(aSubject: Link, provider: Networking) {
        self.subject = aSubject
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aCoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup
        commentsVC = CommentsTableViewController(viewModel: viewModel, parentComment: .None, tableHeaderView: self.selfTextView)
        addChildViewController(commentsVC)
        view.addSubview(commentsVC.view)
        commentsVC.didMoveToParentViewController(self)
        
        // indicator for comments table
        view.insertSubview(indicatorView, aboveSubview: commentsVC.view)
        indicatorView.center = CGPointMake(view.bounds.width / 2, 20)
        indicatorView.hidesWhenStopped = true

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
        }(UIView(frame: CGRectMake(0, 0, 160, 44)))
        navigationItem.titleView = navTitleView
        let replyToPostButton = UIBarButtonItem(title: String.fontAwesomeIconWithName(.Edit), style: .Plain, target: self, action: #selector(DetailsViewController.editPressed))
        replyToPostButton.setTitleTextAttributes([NSFontAttributeName: UIFont.fontAwesomeOfSize(24)], forState: .Normal)
        navigationItem.rightBarButtonItem = replyToPostButton

        viewModel.showSpinner
            .bindTo(indicatorView.rx_animating)
            .addDisposableTo(disposeBag)
    }
    
    func editPressed() {
        
    }
}
