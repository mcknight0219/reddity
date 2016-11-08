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

    lazy var selfTextView: UIView = {
        let selfTextLabel: UILabel = {
            $0.backgroundColor = UIColor.lightGrayColor()
            $0.textAlignment = .Natural
            $0.font = UIFont.SystemFontOfSize(16)
            $0.textColor = UIColor.blackColor()
            $0.text = self.subject.selfType.associatedValue ?? ""

            return $0
        }(UILabel())

        let view = {
            $0.addSubview(selfTextLabel)
        }(UIView())

        selfTextLabel.snp_makeConstraint { make in 
            make.top.bottom.left.right.equalTo(view)
        }

        return view
    }()
    
    //var commentsOSD = [Comment]()
    var comments = [Comment]()
    let subject: Link
    lazy var viewModel: CommentViewModelType = {
        return CommentViewModel(aLink: self.subject, provider: self.provider)
    }()

    init(aSubject: Link, provider: Networking) {
        self.subject = aSubject
        super.init(nibName: nil, bundle: nil)
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
            $0.tableView.cellLayoutMarginsFollowReadableWidth = false
            $0.tableView.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
            $0.tableView.tableFooterView = self.footerView
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
        let replyToPostButton = UIBarButtonItem(title: String.fontAwesomeIconWithName(.Edit), style: .Plain, target: self, action: #selector(DetailsViewController.editPressed))
        replyToPostButton.setTitleTextAttributes([NSFontAttributeName: UIFont.fontAwesomeOfSize(20)], forState: .Normal)
        navigationItem.rightBarButtonItem = replyToPostButton

        // Things that change
        viewModel.updatedContents
            .subscribeOn(MainScheduler.instance)
            .subscribeNext {[weak self] _ in
                self?.commentsVC.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)

        viewModel.showSpinner
            .map { !$0 }
            .bindTo(self.indicatorView.rx_hidden)
            .addDisposableTo(diseposeBag)
    }

    func replyToPostButton() {

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
        cell.configCellWith(&self.commentsOSD[indexPath.row])


        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfComments
    }
}
