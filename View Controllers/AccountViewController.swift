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

        tableView.layoutMargins =  UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero

        self.hideFooter()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Account().isGuest ? 2 : 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        }

        if let cell = cell {
            let bg = UIView()
            cell.selectedBackgroundView = bg

            cell.layoutMargins = UIEdgeInsets.zero
            cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 20)
            cell.detailTextLabel?.font = UIFont(name: "Helvetica Neue", size: 20)

            switch indexPath.row {
            case 0:
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none

            case 1:
                if case(.LoggedInUser(let name)) = Account().user! {
                    cell.textLabel?.text = "Log Out"
                    cell.detailTextLabel?.text = name
                } else {
                    cell.textLabel?.text = "Log In"
                }
            case 2:
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle  = .none

            case 3:
                cell.textLabel?.text = "Delete All Data"
                cell.textLabel?.textColor = UIColor.red
            default:
                break
            }
        }
        
        return cell!
    }

     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        guard row == 1 else { return }

        // Guest out. Remove all search histories for `guest`.
        if Account().isGuest {
            gotoLogin()
            return
        }

        let logoutController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        logoutController.addAction(cancelAction)

        let logoutAction = UIAlertAction(title: "Log Out", style: .default) { [unowned self] (action) in

            var account = Account()
            account.user = .Guest
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            self.gotoLogin()
        }
        logoutController.addAction(logoutAction)

        present(logoutController, animated: true) {}
    }

    func gotoLogin() {
        let vc = StartupViewController()
        vc.modalTransitionStyle = .flipHorizontal
        
        (UIApplication.shared.delegate as! AppDelegate).present(vc: vc)
    }
}
