//
//  SubscriptionViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-02
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD
import ChameleonFramework

class SubscriptionViewController: BaseTableViewController {
 
    let _tapOnBackground = UITapGestureRecognizer()
    lazy var backgroundView: UIView = {
        return {
            let label: UILabel = {
                $0.text = "You don't have any subscription yet."
                $0.font = UIFont(name: "Helvetica Neue", size: 18)
                $0.textColor = UIColor.gray
                $0.numberOfLines = 0
                $0.textAlignment = .center
                
                return $0
            }(UILabel())
            $0.addSubview(label)
            
            let this = $0
            label.snp.makeConstraints { make in
                make.leading.equalTo(this).offset(25)
                make.trailing.equalTo(this).offset(-25)
                make.top.equalTo(UIScreen.main.bounds.height / 2 - 150)
            }
            
            $0.addGestureRecognizer(self._tapOnBackground)

            return $0
        }(UIView())
    }()
    
    lazy var subtitleView: UILabel = {
        return {
            $0.backgroundColor = UIColor.clear
            $0.font = UIFont(name: "Helvetica Neue", size: 14)
            $0.textAlignment = .center
            $0.textColor = UIColor.darkGray
            
            return $0
        }(UILabel(frame: CGRect(x: 0, y: 24, width: 200, height: 44-24)))
    }()
    
    lazy var titleView: UILabel = {
        return {
            $0.backgroundColor = UIColor.clear
            $0.font = UIFont(name: "Helvetica Neue", size: 20)
            $0.textAlignment = .center
            $0.textColor = UIColor.darkGray
            $0.text = "Subscription"

            return $0
        }(UILabel(frame: CGRect(x: 0, y: 2, width: 200, height: 24)))
    }()

    var provider: Networking!
    
    fileprivate var selectedOrderIndex = Variable<Int>(0)
    lazy var viewModel: SubscriptionViewModelType = {
        return SubscriptionViewModel(provider: self.provider, selectedOrder: self.selectedOrderIndex.asObservable())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        hideFooter()
        
        let navTitleView =  UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        navTitleView.backgroundColor = UIColor.clear
        navTitleView.autoresizesSubviews = true
        navTitleView.addSubview(self.titleView)
        navTitleView.addSubview(subtitleView)
        navTitleView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin]
        navigationItem.titleView = navTitleView
        
        let sortButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(SubscriptionViewController.sortItemTapped))
        navigationItem.rightBarButtonItem = sortButton
        
        viewModel
            .showBackground
            .do(onNext: { show in
                if show {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.dismiss()
                }
            }, onError: nil)
            .map { !$0 }
            .bindTo(sortButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        viewModel
            .updatedContents
            .subscribeOn(MainScheduler.instance)
            .map { n in
                return self.tableView
            }
            .do(onNext: { tableView in
                tableView.reloadData()
            }, onError: nil)
            .subscribe(onNext: { [weak self] _ in
                self?.subtitleView.text = "(\(self?.viewModel.numberOfSubscriptions))"
            }, onError: nil)
            .addDisposableTo(disposeBag)

        self.refreshControl!
            .rx.controlEvent(.valueChanged)
            .flatMap { reachabilityManager.reach }
            .subscribe(onNext: {[weak self] on in
                if on {
                    self?.viewModel.reload()
                } else {
                    self?.refreshControl?.endRefreshing()
                }
            }, onError: nil)
            .addDisposableTo(disposeBag)

        viewModel
            .showRefresh
            .asObservable()
            .subscribe(onNext: {[weak self] show in
                if !show {
                    self?.refreshControl?.endRefreshing()
                }
            }, onError: nil)
            .addDisposableTo(disposeBag)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfSubscriptions
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SubscriptionCell")
        }

        cell!.textLabel?.text = self.viewModel.displayNameAtIndexPath(indexPath: indexPath)
        cell!.detailTextLabel?.text = "\(self.viewModel.subscribersAtIndexPath(indexPath: indexPath))"
        cell!.accessoryType = .detailButton
        
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = self.viewModel.displayNameAtIndexPath(indexPath: indexPath)
        
        let timelineVC = TimelineViewController(subredditName: name)
        timelineVC.provider = Networking.newNetworking()
        timelineVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(timelineVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "Unsubscribe") {action in
            self.viewModel.unsubscribe(indexPath: indexPath)
        }
        
        return [deleteAction]
    }
}

// MARK: Sort Functionality
extension SubscriptionViewController {
    func sortItemTapped() {
        let alert = self.sortOrderAlertController()
        present(alert, animated: true, completion: nil)
    }

    func sortOrderAlertController() -> UIAlertController {
        let sortOrderController = UIAlertController(title: "Choose order of subscribed subreddits", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sortOrderController.addAction(cancel)
        
        
        
        _ = ["Alphabetical", "Popularity", "Favorite"].enumerated().map { (index, name) in
            var mod = name
            if self.selectedOrderIndex.value == index {
                mod = mod + "✓"
            }
            
            let op = UIAlertAction(title: mod, style: .default, handler: { [weak self] _ in
                if let weakSelf = self {
                    weakSelf.selectedOrderIndex.value = index
                }
            })
            sortOrderController.addAction(op)
        }
        
        return sortOrderController
    }
}

extension SubscriptionViewController {
    override func applyTheme() {
        let theme = TableViewTheme()
        titleView.textColor = theme?.titleTextColor
    }
}

