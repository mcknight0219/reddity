//
//  DetailsViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-15
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
import SnapKit
import RxSwift

class InsetLabel: UILabel {
    var inset = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
    
    init(_ rect: UIEdgeInsets? = nil) {
        super.init(frame: CGRect.zero)
        if rect != nil && rect != inset {
            inset = rect!
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}


class CommentsTableViewController: BaseTableViewController {
    fileprivate var viewModel: CommentViewModelType
    fileprivate var parentComment: Comment?
    fileprivate var tableHeader: UIView?
    
    fileprivate var reuseBag = DisposeBag()
    
    init(viewModel: CommentViewModelType, parentComment: Comment?, tableHeaderView: UIView?) {
        self.viewModel = viewModel
        self.parentComment = parentComment
        self.tableHeader = tableHeaderView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: life cycle
    
    override func viewDidLoad() {
        
        tableView.frame = UIScreen.main.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
       
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = false

        viewModel
            .updatedContents
            .subscribe(onNext: { _ in
                self.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)
        
        viewModel.showSpinner
            .subscribe(onNext: {[weak self] show in
                if !show {
                    //self?.tableView.tableFooterView = self?.footerView
                } else {
                    self?.tableView.tableFooterView = UIView()
                }
            })
            .addDisposableTo(disposeBag)
    }
}

extension CommentsTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let m = viewModel.commentAtIndexPath(indexPath, parentComment)
        guard m != nil else {
            return
        }
        let actionSheet = UIAlertController(title: "", message: "Reply to @\(m!.user)", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(cancelAction)
        
        let replyAction = UIAlertAction(title: "Reply", style: .default)
        actionSheet.addAction(replyAction)
        
        let downVoteAction = UIAlertAction(title: "Downvote", style: .default)
        actionSheet.addAction(downVoteAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - Table view data source

extension CommentsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = viewModel.commentAtIndexPath(indexPath, self.parentComment)
        cell.configCellWith(aComment: comment!)

        cell.expandRepliesPressed
            .subscribe(onNext: { [weak self]  _ in
                if let ct = self {
                    let vc = CommentsTableViewController(viewModel: ct.viewModel, parentComment: comment, tableHeaderView: nil)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .addDisposableTo(cell.reuseBag)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.parentComment?.replies.count ?? self.viewModel.numberOfComments
    }
    
    
}


class DetailsViewController: BaseViewController {
    
    var commentsVC: CommentsTableViewController!
    
    lazy var indicatorView: UIActivityIndicatorView = {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            return UIActivityIndicatorView(activityIndicatorStyle: .white)
        } else {
            return UIActivityIndicatorView(activityIndicatorStyle: .gray)
        }
    }()
    
    lazy var subtitleView: UILabel = {
        return {
            $0.backgroundColor = UIColor.clear
            $0.font = UIFont(name: "Helvetica Neue", size: 12)
            $0.textAlignment = .center
            $0.textColor = UIColor.darkGray
            
            return $0
        }(UILabel(frame: CGRect(x: 0, y: 24, width: 0.95 * self.view.frame.width, height: 14)))
    }()
    
    lazy var titleView: UILabel = {
        return {
            $0.backgroundColor = UIColor.clear
            $0.font = UIFont(name: "Helvetica Neue", size: 16)
            $0.textAlignment = .center
            $0.textColor = UIColor.black
            $0.numberOfLines = 1
            
            return $0
        }(UILabel(frame: CGRect(x: 0, y: 0, width: 0.95 * self.view.frame.width, height: 30)))
    }()

    lazy var selfTextView: UIView? = {
        guard case .selfText = self.subject.selfType else {
            return nil
        }
        
        let selfTextLabel: UILabel = {
            $0.backgroundColor = UIColor.lightGray
            $0.textAlignment = .natural
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.textColor = UIColor.black
            $0.text = self.subject.selfType.associatedValue ?? ""
            
            return $0
        }(UILabel())
        
        let view: UIView = {
            $0.addSubview(selfTextLabel)
            return $0
        }(UIView())
        
        selfTextLabel.snp.makeConstraints { make in
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
        commentsVC = CommentsTableViewController(viewModel: viewModel, parentComment: .none, tableHeaderView: self.selfTextView)
        addChildViewController(commentsVC)
        view.addSubview(commentsVC.view)
        commentsVC.didMove(toParentViewController: self)
        
        // indicator for comments table
        view.insertSubview(indicatorView, aboveSubview: commentsVC.view)
        indicatorView.center = CGPoint(x: view.bounds.width / 2, y: 20)
        indicatorView.hidesWhenStopped = true
        
        navigationItem.title = subject.title
        
        let replyToPostButton = UIBarButtonItem(title: "Reply", style: .plain, target: self, action: #selector(DetailsViewController.editPressed))
                navigationItem.rightBarButtonItem = replyToPostButton
        
        viewModel.showSpinner
            .bindTo(indicatorView.rx.isAnimating)
            .addDisposableTo(disposeBag)
    }
    
    func editPressed() {
        
    }
}
