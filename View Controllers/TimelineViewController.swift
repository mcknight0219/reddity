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
import Moya

extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}


class TimelineViewController: BaseViewController {

    var topicTableViewController: BaseTableViewController!

    lazy var tableView: UITableView = {
        return self.topicTableViewController.tableView
    }()

    lazy var refresh: UIRefreshControl = {
        return self.topicTableViewController.refreshControl!
    }()
    
    var subredditName: String = ""
    var isFromSearch: Bool = false
    
    var provider: Networking!
    lazy var viewModel: TimelineViewModelType = {
        let nextPageTrigger = self.tableView.rx_contentOffset
            .flatMap { _ in
                self.tableView.isNearBottomEdge()
                    ? Observable.just(())
                    : Observable.empty()
        }
        
        return TimelineViewModel(subreddit: self.subredditName, provider: self.provider, loadNextPageTrigger: nextPageTrigger)
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
            $0.refreshControl = UIRefreshControl()
            $0.tableView.tableFooterView = UIView()
            
            return $0
        }(BaseTableViewController())
        tableView.delegate = self
        tableView.dataSource = self
        ["NewsCell", "ImageCell", "TextCell"].forEach {
            tableView.registerNib(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
        addChildViewController(topicTableViewController)
        view.addSubview(topicTableViewController.view)
        topicTableViewController.didMoveToParentViewController(self)
        
        viewModel
            .isRefreshing
            .asObservable()
            .subscribeNext { refreshing in
                if !refreshing {
                    self.refresh.endRefreshing()
                }
            }
            .addDisposableTo(disposeBag)

        refresh
            .rx_controlEvent(.ValueChanged)
            .flatMap { () -> Observable<Bool> in
                return reachabilityManager.reach
            }
            .subscribeNext { on in
                if on {
                    self.viewModel.reload()
                } else {
                    self.refresh.endRefreshing()
                }
            }
            .addDisposableTo(disposeBag)
        

        viewModel
            .updatedContents
            .subscribeOn(MainScheduler.instance)
            .map { _ in
                return self.tableView
            }
            .doOnNext { tableView in
                tableView.reloadData()
            }
            .subscribeNext { _ in
                
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK: Table view data source delegate

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfLinks
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let linkViewModel = self.viewModel.linkViewModelAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(linkViewModel.cellType.identifier, forIndexPath: indexPath) as! ListingTableViewCell
        cell.setViewModel(linkViewModel)
        
        return cell
    }
}

// MARK: Table view delegate

extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let vm = self.viewModel.linkViewModelAtIndexPath(indexPath)
        return vm.cellHeight
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}
