//
//  BaseTableViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class BaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.tableView.backgroundColor = FlatBlackDark()
            self.tableView.separatorColor = UIColor(colorLiteralRed: 0.11, green: 0.11, blue: 0.16, alpha: 1.0)
            self.tableView.indicatorStyle = .White
            self.tableView.tableFooterView?.backgroundColor = FlatBlackDark()
        } else {
            self.tableView.backgroundColor = UIColor(colorLiteralRed: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
            self.tableView.separatorColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.01, alpha: 1.0)
            self.tableView.indicatorStyle = .Default
            self.tableView.tableFooterView?.backgroundColor = UIColor(colorLiteralRed: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
        }
    }
}
