//
//  StorageViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-03.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SDWebImage
import ChameleonFramework

class StorageViewController: BaseTableViewController {

    lazy var dataSize: UInt64 = {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let sys = NSFileManager.defaultManager()
        if !sys.fileExistsAtPath(app.storagePath) { return 0 }

        let enumerator = sys.enumeratorAtPath(app.storagePath)
        var size: UInt64 = 0
        while let f = enumerator?.nextObject() as? String {
            let attrs: NSDictionary = try! sys.attributesOfItemAtPath((app.storagePath as NSString).stringByAppendingPathComponent(f))
            size += attrs.fileSize()
        }

        return size
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Storage"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Lato-Regular", size: 20)!]
    
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        self.tableView.tableFooterView = UIView()
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
            bg.backgroundColor = UIColor.grayColor()
            cell.selectedBackgroundView = bg
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 20)
            cell.detailTextLabel?.font = UIFont(name: "Lato-Regular", size: 20)
            
            let cachedSize = UInt64(SDImageCache.sharedImageCache().getSize()) / 1048576
            let storedSize = dataSize
            
            switch indexPath.row {
            case 0:
                cell.backgroundColor = UIColor.clearColor()
                cell.selectionStyle = .None
                cell.layoutMargins = UIEdgeInsetsZero
            case 1:
                cell.textLabel?.text = "Total Storage"
                cell.detailTextLabel?.text = "\(cachedSize + storedSize) Mb"
                cell.selectionStyle = .None
                cell.layoutMargins = UIEdgeInsetsZero
            case 2:
                cell.backgroundColor = UIColor.clearColor()
                cell.selectionStyle = .None
                cell.layoutMargins = UIEdgeInsetsZero
            case 3:
                cell.textLabel?.text = "Cached Image"
                cell.detailTextLabel?.text = "\(cachedSize) Mb"
            case 4:
                cell.textLabel?.text = "Stored On Disk"
                cell.detailTextLabel?.text = "\(storedSize) Mb"
                cell.layoutMargins = UIEdgeInsetsZero
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
            self.tableView.reloadData()
        }
        let delStoredAction = UIAlertAction(title: "Delete", style: .Destructive) { _ in
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                self.rm()
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        if row == 3 { delController.addAction(delCacheAction) }
        else if row == 4 { delController.addAction(delStoredAction) }
        delController.addAction(cancelAction)
        delController.view.tintColor = UIColor.blueColor()
        
        self.presentViewController(delController, animated: true) {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                SDImageCache.sharedImageCache().clearMemory()
                SDImageCache.sharedImageCache().clearDisk()
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
        
    }
}

extension StorageViewController {
    /**
     * Clear all files in app's `Data` directory
     */
    func rm() {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let sys = NSFileManager.defaultManager()
        if !sys.fileExistsAtPath(app.storagePath) { return }

        let enumerator = sys.enumeratorAtPath(app.storagePath)
        while let f = enumerator?.nextObject() as? String {
            try! sys.removeItemAtPath((app.storagePath as NSString).stringByAppendingPathComponent(f))
        }
    }
}
