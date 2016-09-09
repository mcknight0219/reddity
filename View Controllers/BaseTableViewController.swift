//
//  BaseTableViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol ReachabilityUpdateProtocol {
    func updateUIWithReachability()
}

class BaseTableViewController: UITableViewController {

    private var internalReachabilityStatus = Reachability.sharedInstance.status

    lazy var reachabilityBackground: UILabel! = {
        let label = UILabel()
        label.text = "(You are not connected to Internet. Try again later.)"
        label.font = UIFont(name: "Lato-Regular", size: 18)!
        label.textColor = FlatWhiteDark()
        label.numberOfLines = 0
        label.textAlignment = .Center

        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyTheme()
        self.updateUIWithReachability()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewController.reachabilityChanged(_:)), name: kNetworkReachabilityChanged, object: nil)
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

       
    func reachabilityChanged(notification: NSNotification) {
        let reachability = notification.object as! Reachability
        if reachability.status == internalReachabilityStatus {
            return
        }
        
        internalReachabilityStatus = reachability.status
        self.updateUIWithReachability()
    }
}

/**
 Subclass of this class should implement this method in order to 
 update interface after reachability changes

 
 */
extension BaseTableViewController: ReachabilityUpdateProtocol {
    func updateUIWithReachability() {}
}
