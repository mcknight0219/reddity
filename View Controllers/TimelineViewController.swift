//
//  TimelineViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
import SafariServices
import FontAwesome_swift
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
import Action
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
                    ? Observable.just(NSDate())
                    : Observable.empty()
        }
        
        return TimelineViewModel(subreddit: self.subredditName, provider: self.provider, loadNextPageTrigger: nextPageTrigger)
    }()
    
    lazy var loadingFooterView: UIView = {
        let view: UIView = {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            indicator.startAnimating()
            $0.addSubview(indicator)
            $0.backgroundColor = CellTheme()!.backgroundColor
            indicator.center = $0.center
            
            return $0
        }(UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 45)))
        
        return view
    }()
    
    var referencePhoto: UIView?
    
    var lastContentOffset: CGFloat = 0
    var videoCurrentlyPlaying: Bool = false
    var notScrolled: Bool = true
    
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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "avator"), style: .Plain, target: self, action: #selector(TimelineViewController.showAccountPopover))
        
        automaticallyAdjustsScrollViewInsets = true
        topicTableViewController = {
            $0.view.frame = view.bounds
            $0.refreshControl = UIRefreshControl()
            $0.tableView.tableFooterView = UIView()
            $0.tableView.rowHeight = UITableViewAutomaticDimension
            $0.tableView.estimatedRowHeight = 250
          
            return $0
        }(BaseTableViewController())
        tableView.delegate = self
        tableView.dataSource = self
        ["NewsCell", "ImageCell", "TextCell", "VideoCell"].forEach {
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
        
        viewModel
            .showLoadingFooter
            .subscribeNext { show in
                if show {
                    self.tableView.tableFooterView = self.loadingFooterView
                } else {
                    self.tableView.tableFooterView = UIView()
                }
            }
            .addDisposableTo(disposeBag)
        
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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelineViewController.archiveTimeline), name: "ArchiveTimelineHistory", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelineViewController.signIn), name: "SignInNotification", object: nil)
    }

    @objc private func archiveTimeline() {
    }
    
    @objc private func signIn() {
        let signInVC = SignInViewController()
        signInVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(signInVC, animated: true)
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
        
        // Map tapping on image
        if let imageCell = cell as? ImageCell {
            imageCell.tapOnPicture
                .observeOn(MainScheduler.instance)
                .subscribeNext { [weak self] _ in
                    if let URL = linkViewModel.resourceURL, let weakSelf = self {
                        let photosViewController = PhotosViewController(photos: [URL], initialPhoto: URL, delegate: weakSelf)
                        weakSelf.referencePhoto = imageCell.picture
                        weakSelf.presentViewController(photosViewController, animated: true, completion: nil)
                    }
                }
                .addDisposableTo(disposeBag)
        }
        
        if let newsCell = cell as? NewsCell {
            newsCell
                .tapOnPicture
                .observeOn(MainScheduler.instance)
                .subscribeNext { _ in
                    if let URL = NSURL(string: linkViewModel.URL) {
                        let safariViewController = SFSafariViewController(URL: URL)
                        self.presentViewController(safariViewController, animated: true, completion: nil)
                    }

                }
                .addDisposableTo(newsCell.reuseBag)
        }
        
        return cell
    }
}

// MARK: UIScrollViewDelegate

extension TimelineViewController {
    enum ScrollDirection {
        case Up
        case Down
        case Still
    }
    
    private func detectScrollDirection(currentContentOffset: CGPoint) -> ScrollDirection {
        self.lastContentOffset = currentContentOffset.y
        return self.lastContentOffset > currentContentOffset.y ? .Up
            : (self.lastContentOffset < currentContentOffset.y ? .Down : .Still)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if notScrolled { notScrolled = false }
        let dir = detectScrollDirection(scrollView.contentOffset)
        let tableView = scrollView as! UITableView
        if let visible = tableView.indexPathsForVisibleRows {
            for i in visible {
                let rect = tableView.rectForRowAtIndexPath(i)
                if tableView.bounds.intersects(rect) && !tableView.bounds.contains(rect) {
                    if let cell = tableView.cellForRowAtIndexPath(i) as? VideoCell {
                        switch dir {
                        case .Down:
                            cell.stopVideoPlay()
                        default:
                            break
                        }
                    }
                } else if tableView.bounds.contains(rect) {
                    
                }
            }
            
            visible.forEach { ip in
                let rect = tableView.rectForRowAtIndexPath(ip)
                let container = tableView.bounds
                if let cell = tableView.cellForRowAtIndexPath(ip) as? VideoCell {
                    if container.contains(rect) {
                        
                    }
                }
            }
        }
    }
}


// MARK: PhotosViewControllerDelegate

extension TimelineViewController: PhotosViewControllerDelegate {
    func photosViewController(vc: PhotosViewController, referenceViewForPhoto photo: NSURL) -> UIView? {
        return self.referencePhoto
    }
    
    func photosViewController(vc: PhotosViewController, didNavigateToPhoto photo: NSURL, atIndex index: Int) {
        print("photosViewController:didNavigateToPhoto")
    }
    
    func photosViewControllerWillDismiss(vc: PhotosViewController) {
        print("photosViewControllerWillDismiss")
    }
    
    func photosViewControllerDidDismiss(vc: PhotosViewController) {
        print("photosViewControllerDidDismiss")
    }
}


// MARK: Table view delegate

extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let linkViewModel = self.viewModel.linkViewModelAtIndexPath(indexPath)
        
        let vc = DetailsViewController(aSubject: linkViewModel.link, provider: self.provider)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TimelineViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
    
    @objc func showAccountPopover() {
        let popover = AccountSwitchViewController()
        popover.modalPresentationStyle = .Popover
        let height: CGFloat = CGFloat(Account().numberOfAccounts + 1) * 66.0 + 66.0
        popover.preferredContentSize = CGSizeMake(self.view.frame.width * 0.95, height)
    
        if let presentation = popover.popoverPresentationController {
            presentation.delegate = self
            presentation.barButtonItem = navigationItem.rightBarButtonItem
        }
        presentViewController(popover, animated: true, completion: nil)
    }
}
