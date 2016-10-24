//
//  AccountViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-03.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class AccountViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Account"
        navigationController?.navigationBar.titleTextAttributes![NSFontAttributeName] = UIFont(name: "Lato-Regular", size: 20)!

        tableView.layoutMargins =  UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero

        let footer = UIView()
        tableView.tableFooterView = footer
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Account().isGuest ? 2 : 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = BaseTableViewCell(style: .Value1, reuseIdentifier: "Cell")
        }

        if let cell = cell {
            let bg = UIView()
            cell.selectedBackgroundView = bg

            cell.layoutMargins = UIEdgeInsetsZero
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 20)
            cell.detailTextLabel?.font = UIFont(name: "Lato-Regular", size: 20)

            switch indexPath.row {
            case 0:
                cell.backgroundColor = UIColor.clearColor()
                cell.selectionStyle = .None

            case 1:
                if case(.LoggedInUser(let name)) = Account().user! {
                    cell.textLabel?.text = "Log Out"
                    cell.detailTextLabel?.text = name
                } else {
                    cell.textLabel?.text = "Log In"
                }
            case 2:
                cell.backgroundColor = UIColor.clearColor()
                cell.selectionStyle  = .None

            case 3:
                cell.textLabel?.text = "Delete All Data"
                cell.textLabel?.textColor = UIColor.redColor()
            default:    break
            }
        }
        
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        guard row == 1 else { return }

        // Guest out. Remove all search histories for `guest`.
        if Account().isGuest {
            gotoLogin()
            return
        }

        let logoutController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        logoutController.addAction(cancelAction)

        let logoutAction = UIAlertAction(title: "Log Out", style: .Default) { [unowned self] (action) in

            var account = Account()
            account.user = .Guest
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isLoggedIn")
            self.gotoLogin()
        }
        logoutController.addAction(logoutAction)

        presentViewController(logoutController, animated: true) {}
    }

    func gotoLogin() {
        let vc = StartupViewController()
        vc.modalTransitionStyle = .FlipHorizontal
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).presentVC(vc)
    }
}
