//
//  CommentsViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-15
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController {
    
    var commentsVC: UITableViewController!
    
    var headView: UIView!
    let subject: Link
    var comments: [Comment]
    
    init(aSubject: Link, comments: [Comment]) {
        super.init(nibName: nil, bundle: nil)

        self.subject = aSubject
        self.comments = comments
    }

    required init?(coder aCoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()

        initCommentsShownStatus()

        headView = UIView()
        let w = UIScreen.mainScreen().bounds.width
        let h = UIScreen.mainScreen().bounds.height
        headView.frame = CGRectMake(0, 0, w, w * 0.7)
        let headImage = UIImage()
        headImage.frame = headView.bounds
        headView.addSubview(headImage)
        
        commentsVC = UITableViewController()
        addChildViewController(commentsVC)
        commentsVC.view.frame = CGRectMake(0, w, w, h - w * 0.7)
        view.addSubview(commentsVC.view)
        commentsVC.didMoveToParentViewController(self)
        commentsVC.tableView.dataSource = comments
        
        self.setupUI()
    }

    private func setupUI() {
        navigationItem.title = "Title"
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        commentsVC.automaticallyAdjustScrollViewInsects = false
    }

    private func initCommentsShownStatus() {
       guard commentsCount() > 15 else { return }

       comments.flatMap { }
    }

    private func commentsCount() -> Int {
        return self.comments.reduce(0) { $0 + $1.totalReplies() }
    }
}

// MARK: - Table view data source

extension CommentsViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, heigthForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
