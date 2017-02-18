//
//  BaseTableViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SVProgressHUD
#if !RX_NO_MODULE
import RxSwift
#endif

class BaseTableViewController: UITableViewController {
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reachabilityManager
            .reach
            .take(1)
            .subscribe(onNext: { connected in
                if !connected {
                    SVProgressHUD.showError(withStatus: "No Internet Connection.")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                }             
            })
            .addDisposableTo(disposeBag)

        self.applyTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(BaseTableViewController.applyTheme), name: Notification.Name.onThemeChanged, object: nil)
    }

    func applyTheme() {
        let theme = TableViewTheme()!
        
        self.tableView.backgroundColor = theme.backgroundColor
        self.tableView.separatorColor  = theme.separatorColor
        self.tableView.indicatorStyle  = theme.indicatorStyle
        self.tableView.tableFooterView?.backgroundColor = theme.backgroundColor
    }
    
    func hideFooter() {
        tableView.tableFooterView = UIView()
    }
}
