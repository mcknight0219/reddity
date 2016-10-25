//
//  TimelineViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
import FontAwesome_swift
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}


class TimelineViewController: BaseViewController {

    var topicTableViewController: TopicTableViewController!
    var topicDataSource: TopicDataSource!

    lazy var tableView: UITableView = {
        return topicTableViewController.tableView
    }()

    lazy var refresh: UIRefreshControl = {
        return topicTableViewController.refreshControl!
    }()
    
    var subredditName: String = ""
    var isFromSearch: Bool = false
    
    var provider: Networking!
    lazy var viewModel: TimelineViewModelType = {
        let nextPageTrigger = tableView.rx_contentOffset
            .flatMap { _ in
                self.tableView.isNearBottomEdge()
                    ? Observable.just(())
                    : Observable.empty()
        }
        
        return TimelineViewModel(subreddit: self.subredditName, provider: self.provider, loadNextPageTrigger: nextPageTrigger))
    }()
    
    init(subredditName: String) {
        super.init(nibName: nil, bundle: nil)
        self.subredditName = subredditName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = subredditName.isEmpty ? "Front Page" : subredditName
        automaticallyAdjustsScrollViewInsets = true
        
        topicTableViewController = {
            $0.view.frame = view.bounds
            $0.dataSource = self
            $0.delegate = self
            $0.refreshControl = UIRefreshControl()
            $0.tableView.tableFooterView = UIView()
            
            return $0
        }(TopicTableViewController())
        ["NewsCell", "ImageCell", "TextCell"].map {
            tableView.registerNib(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
        addChildViewController(topicTableViewController)
        view.addSubview(topicTableViewController.view)
        topicTableViewController.didMoveToParentViewController(self)
        
        // Map showSpinner to HUD status
        viewModel
            .showSpinner
            .subscribeNext { show in
                if show {
                    HUDManager.sharedInstance.showCentralActivityIndicator()
                } else {
                    HUDManager.sharedInstance.hideCentralActivityIndicator()
                }
            }
            .addDisposableTo(disposeBag)

        viewModel
            .isRefreshing
            .drive(refresh.refreshing)
            .addDisposableTo(disposeBag)

        refresh
            .rx_controlEvent(.ValueChanged)
            .map {[weak self] _ in 
                self.viewModel.reload()
            }
            .addDisposableTo(disposeBag)

        viewModel
            .updatedContents
            .mapReplace(tableView)
            .doOnNext { tableView in
                tableView.reloadData()
            }
            .dispatchAsyncMainScheduler()
            .subscribeNext { [weak self] tableView in 
                tableView.scrollToTop()
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK: Table view data source delegate

extension TimelineViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 15
    }

    override func tableView(tableView: UITableView, numberOfRowsInsection section: Int) -> Int {
        return self.viewModel.numberOfLinks
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let linkViewModel = self.viewModel.linkViewModelAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(linkViewModel.cellIndentifier, forIndexPath: indexPath)
        
        if let linkCell = cell as? LinkTableViewCell {
            linkCell.viewModel = linkViewModel
        }
        
        switch linkVoewModel.cellIdentifier {
        case "ImageCell":
            return linkCell as! ImageCell
        case "NewsCell":
            return linkCell as! NewsCell
        case "TextCell":
            return linkCell as! TextCell
        }
    }
}

// MARK: Table view delegate

extension TimelineViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.viewModel.linkViewModelAtIndexPath(indexPath).height    
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}
