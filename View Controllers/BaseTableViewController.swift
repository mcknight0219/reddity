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
        if ThemeManager.defaultManager().currentTheme == "Dark" {
            self.tableView.backgroundColor = FlatDark()        
            self.tableView.separatorColor = FlatWhite()
            self.tableView.indicatorStyle = .White
        } else {
            self.tableView.backgroundCOlor = FlatWhite()
            self.tableView.separatorColor = FlatDark()
            self.tableView.indicatorStyle = .Default
        }
    }
}
