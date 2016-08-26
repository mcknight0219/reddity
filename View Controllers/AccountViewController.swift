//
//  AccountViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-03.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class AccountViewController: UITableViewController {

    lazy var app: AppDelegate = {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }()

    lazy var user: String = { 
        return app.user
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Account"
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
        view.backgroundColor = UIColor.whiteColor()

        tableView.layoutMargins =  UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero

        let footer = UIView()
        footer.backgroundColor = FlatWhite()
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
        return user == 'guest' ? 2 : 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "Cell")
        }

        if let cell = cell {
            let bg = UIView()
            bg.backgroundColor = UIColor(colorLiteralRed: 252/255, green: 126/255, blue: 15/255, alpha: 0.05)
            cell.selectedBackgroundVoew = bg

            cell.layoutMargins = UIEdgeInsetsZero
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 20)
            cell.detailTextLabel?.font = UIFont(name: "Lato-Regular", size: 20)

            switch indexPath.row {
            case 0:
                cell.backgroundColor = FlatWhite()
                cell.selectionStyle = .None

            case 1:
                if self.user == 'guest' {
                    cell.textLabel?.text = "Log In"
                } else {
                    cell.textLabel?.text = "Log Out"
                    cell.detailTextLabel?.text = self.user
                }
            case 2:
                cell.backgroundColor = FlatWhite()
                cell.selectionStyle  = .None

            case 3:
                cell.textLabel?.text = "Delete All Data"
                cell.textLabel?.textColor = UIColor.redColor()
            default:    break
            }
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        guard row == 1 else { return }

        // Guest out. Remove all search histories for `guest`.
        if self.user == "guest" {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                do {
                    app.database.executeUpdate("DELETE FROM search_history WHERE user = ?", values: [user])    
                } catch let error as NSError {
                    print("failed: \(error.localizedDescription)")
                }
            }
            gotoLogin()
            return
        }

        let logoutController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        logoutController.addAction(cancelAction)

        let logoutAction = UIAlertAction(title: "Log Out", style: .Default) { (action) in
            app.user = 'guest'      // reset current user to `guest`
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isLoggedIn")
            gotoLogin()
        }
        logoutController.addAction(logoutAction)

        presentViewController(logoutController, animated: true) {}
    }

    func gotoLogin() {
        let vc = StartupViewController()
        vc.modalTransitionStyle = .FlipHorizontal
        app.presentVC(vc, withToken: false)
    }
}
