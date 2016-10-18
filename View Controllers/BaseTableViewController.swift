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

    lazy var reachabilityBackground: UILabel! = {
        let label: UILabel = {
            $0.text = "(You are not connected to Internet. Try again later.)"
            $0.font = UIFont(name: "Lato-Regular", size: 18)!
            $0.textColor = FlatWhiteDark()
            $0.numberOfLines = 0
            $0.textAlignment = .Center
            return $0
        }(UILabel())

        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyTheme()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.tableView.backgroundColor = UIColor(colorLiteralRed: 33/255, green: 34/255, blue: 45/255, alpha: 1.0)
            self.tableView.separatorColor = UIColor.darkGrayColor()
            self.tableView.indicatorStyle = .White
            self.tableView.tableFooterView?.backgroundColor = UIColor(colorLiteralRed: 33/255, green: 34/255, blue: 45/255, alpha: 1.0)
        } else {
            self.tableView.backgroundColor = UIColor(colorLiteralRed: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
            self.tableView.separatorColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.01, alpha: 1.0)
            self.tableView.indicatorStyle = .Default
            self.tableView.tableFooterView?.backgroundColor = UIColor(colorLiteralRed: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
        }

    }
    
}
