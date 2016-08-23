//
//  StorageViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-03.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class StorageViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Storage"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
        self.view.backgroundColor = UIColor.whiteColor()
    
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        let footer = UIView()
        footer.backgroundColor = FlatWhite()
        self.tableView.tableFooterView = footer
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "Cell")
        }
        
        if let cell = cell {
        
            let bg = UIView()
            bg.backgroundColor = UIColor(colorLiteralRed: 252/255, green: 126/255, blue: 15/255, alpha: 0.05)
            cell.selectedBackgroundView = bg
            
            cell.layoutMargins = UIEdgeInsetsZero
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 20)
            cell.detailTextLabel?.font = UIFont(name: "Lato-Regular", size: 20)
            
            let cachedSize = RTWebImageManager.sharedManager.cache.size / 1024 / 1024
            let storedSize = 0
            
            switch indexPath.row {
            case 0:
                cell.backgroundColor = FlatWhite()
                cell.selectionStyle = .None
                
            case 1:
                cell.textLabel?.text = "Total Storage"
                cell.detailTextLabel?.text = "\(cachedSize + storedSize) Mb"
                cell.selectionStyle = .None
                
            case 2:
                cell.backgroundColor = FlatWhite()
                cell.selectionStyle = .None
                
            case 3:
                cell.textLabel?.text = "Cached Image"
                cell.detailTextLabel?.text = "\(cachedSize) Mb"
                
                
            case 4:
                cell.textLabel?.text = "Stored On Disk"
                cell.detailTextLabel?.text = "\(storedSize) Mb"
            default: break
            }
        
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        var title: String!
        var message: String!
        if row == 3 {
            title = "Delete Cache"
            message = "Delete all cached images ?"
        } else if row == 4 {
            title = "Delete Offline Data"
            message = "Delete all stored data for offline browsing ?"
        } else { return }
        
        let delController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let delCacheAction = UIAlertAction(title: "Delete", style: .Destructive) { _ in
            RTWebImageManager.sharedManager.cache.removeAllObjects()
            self.tableView.reloadData()
        }
        let delStoredAction = UIAlertAction(title: "Delete", style: .Destructive) { _ in
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        if row == 3 { delController.addAction(delCacheAction) }
        else if row == 4 { delController.addAction(delStoredAction) }
        delController.addAction(cancelAction)
        delController.view.tintColor = FlatOrange()
        
        self.presentViewController(delController, animated: true) {
        }
        
    }

}
