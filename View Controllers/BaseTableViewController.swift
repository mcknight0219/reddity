//
//  BaseTableViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reachabilityManager
            .reach
            .take(1)
            .subscribeNext { connected in
                let hud = HudManager.sharedInstance
                if !connected {
                    hud.showToast(withTitle: "No Internet Connection.")
                }             
            }

        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
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
