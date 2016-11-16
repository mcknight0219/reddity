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

    var nsfwSwitch: UISwitch!

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
            $0.onTintColor = UIColor.greenColor()
            return $0
        }(UISwitch())
        
        self.nsfwSwitch = {
            $0.onTintColor = UIColor.greenColor()
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
        
        let nsfwOn = Variable(true)
        nsfwSwitch.rx_value <-> nsfwOn
        nsfwOn.asObservable()
            .subscribeNext { _ in
            }
            .addDisposableTo(disposeBag)
    }

    enum Section: Int {
        case AccountAndStorage = 0
        case Settings
        case About

        init?(sec: Int) {
            switch sec {
            case 0:
                self = AccountAndStorage
            case 1:
                self = Settings
            case 2:
                self = Abount
            default:
                self = nil
            }
        }

        static func numberOfSections() -> Int {
            return 3
        }

        var numberOfRows: Int {
            switch self {
            case AccountAndStorage:
                return 2
            case Settings:
                return 3
            case About:
                return 1
            }
        }

        var height: CGFloat {
            return 44
        }

        var title: String {
            switch self {
            case AccountAndStorage:
                return ""
            case Settings:
                return "General"
            case Abount:
                return ""
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.numberOfSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section(section).numberOfRows    
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Section(indexPath.section).height
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> UIView? {
        return Section(indexPath.section).title
    }

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as UITableViewHeaderFooterView         
        header.contentView.backgroundColor = UIColor.clearColor()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SettingCell", forIndexPath: indexPath)
        // Common cell settings
        cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 18)
        cell.accessoryType = .DiscolosureIndicator

        switch Section(indexPath.section) {
        case .AccountAndStorage:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Account"
            } else {
                cell.layoutMargins = UIEdgeInsetsZero
            }
        case .Settings:
            swithch indexPath.row {
            case 0:
                cell.textLabel?.text = "Dark theme"
                cell.accessoryView = themeSwitch
            case 1:
                cell.textLabel?.text = "Show NSFW content"
                cell.accessoryView = nsfwSwitch
            case 2:
                cell.textLabel?.text = "Type size"
                cell.detailTextLabel?.text = Settings().typeSize.rawValue
            case 3:
                cell.textLabel?.text = "Video auto-play"
                cell.detailTextLable?.text = Settings().videoAutoplay.rawValue
                cell.layoutMargins = UIEdgeInsetsZero
            default:
                break
            }
        case .Abount:
            cell.textLabel?.text = "Abount Reddity"
            cell.layoutMargins = UIEdgeInsetsZero
        }
                
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch Section(indexPath.section) {
        case .AccountAndStorage:
            switch indexPath.row {
            case 0:
                let accountVC: AccountViewController = {
                    $0.hidesBottomBarWhenPushed = true
                    $0.modalPresentationStyle = .FullScreen
                    return $0
                }(AccountViewController())
                navigationController?.pushViewController(accountVC, animated: true)
            case 1:
                let storageVC: StorageViewController = {
                    $0.hidesBottomBarWhenPushed = true
                    $0.modalPresentationStyle = .FullScreen
                    return $0
                }(StorageViewController())
                navigationController?.pushViewController(storageVC, animated: true)
            default:
                break
            }
        }
    }

}
