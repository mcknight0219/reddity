//
//  MeViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-02
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import SnapKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class MeViewController: BaseTableViewController {
    
    var themeSwitch: UISwitch!

    var offlineSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        self.navigationController?.navigationBar.titleTextAttributes![ NSFontAttributeName] = UIFont(name: "Lato-Regular", size: 20)!
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.tableFooterView = UIView()

        self.themeSwitch = {
            $0.onTintColor = FlatBlue()
            return $0
        }(UISwitch())
        
        self.offlineSwitch = {
            $0.onTintColor = FlatBlue()
            return $0
        }(UISwitch())
        
        let darkThemeOn = Variable(ThemeManager.defaultManager.currentTheme != "Dark")
        themeSwitch.rx_value <-> darkThemeOn
        
        darkThemeOn
            .asObservable()
            .subscribeNext { x in
                ThemeManager.defaultManager.setTheme(x ? "Dark" : "Default")
            }
            .addDisposableTo(disposeBag)
        
        let offlineOn = Variable(true)
        themeSwitch.rx_value <-> offlineOn
        offlineOn.asObservable()
            .subscribeNext { _ in
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SettingCell", forIndexPath: indexPath)
        
        let r = indexPath.row
        if r == 0 {
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = .None
            cell.layoutMargins = UIEdgeInsetsZero
        } else if r == 1 {
            cell.textLabel?.text = "Account"
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 20)
            cell.accessoryType = .DisclosureIndicator
        } else if r == 2 {
            cell.textLabel?.text = "Storage"
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 20)
            cell.accessoryType = .DisclosureIndicator
            cell.layoutMargins = UIEdgeInsetsZero
        } else if r == 3 {
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = .None
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        } else if r == 4 {
            cell.textLabel?.text = "BEHAVIOR"
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = .None
            cell.layoutMargins = UIEdgeInsetsZero
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 17)
        } else if r == 5 {
            cell.textLabel?.text = "Dark Theme"
            cell.accessoryView = themeSwitch
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 20)
        } else if r == 6 {
            cell.textLabel?.text = "Play Video Automatically"
            cell.accessoryView = UISwitch()
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 20)
        } else if r == 7 {
            cell.textLabel?.text = "Enable Offline"
            cell.accessoryView = offlineSwitch
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 20)
            cell.layoutMargins = UIEdgeInsetsZero
        } else if r == 8 {
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = .None
            cell.layoutMargins = UIEdgeInsetsZero
        } else if r == 9 {
            cell.textLabel?.text = "About"
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 20)
            cell.accessoryType = .DisclosureIndicator
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        if row == 1 {
            let accountVC = AccountViewController()
            accountVC.hidesBottomBarWhenPushed = true
            accountVC.modalPresentationStyle = .FullScreen
            navigationController?.pushViewController(accountVC, animated: true)
        }

        if row == 2 {
            let storageVC = StorageViewController()
            storageVC.hidesBottomBarWhenPushed = true
            storageVC.modalPresentationStyle = .FullScreen
            navigationController?.pushViewController(storageVC, animated: true)
        }
    }

}
