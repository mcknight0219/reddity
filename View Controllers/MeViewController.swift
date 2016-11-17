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

        self.tableView.tableFooterView = UIView()
        
        self.themeSwitch = {
            $0.onTintColor = UIColor.greenColor()
            return $0
        }(UISwitch())
        
        self.nsfwSwitch = {
            $0.onTintColor = UIColor.greenColor()
            return $0
        }(UISwitch())
        
        let darkThemeOn = Variable(Settings().theme == .Dark)
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
                self = About
            default:
                return nil
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
                return 4
            case About:
                return 1
            }
        }

        var title: String {
            switch self {
            case AccountAndStorage:
                return ""
            case Settings:
                return "General"
            case About:
                return ""
            }
        }
        
        var height: CGFloat {
            switch self {
            case Settings:
                return 50
            default:
                return 40
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.numberOfSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.init(sec: section)!.numberOfRows
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sec = Section.init(sec: section)!
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, sec.height))
        view.backgroundColor = UIColor.clearColor()
        
        let sep = UIView(frame: CGRectMake(0, view.frame.size.height-0.5, view.frame.size.width, 0.5))
        sep.backgroundColor = UIColor(colorLiteralRed: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        view.addSubview(sep)
        
        if case .Settings = sec {
            let titleLabel = UILabel(frame: CGRectMake(15, 20, tableView.frame.size.width, 40))
            titleLabel.backgroundColor = UIColor.clearColor()
            titleLabel.text = sec.title
            titleLabel.font = UIFont.systemFontOfSize(15)
            
            view.addSubview(titleLabel)
        }
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Section.init(sec: section)!.height
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("SettingCell")
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "SettingCell")
        }
        // Common cell settings
        cell!.textLabel?.font = UIFont.systemFontOfSize(16)
        cell!.accessoryType = .DisclosureIndicator

        switch Section.init(sec: indexPath.section)! {
        case .AccountAndStorage:
            if indexPath.row == 0 {
                cell!.textLabel?.text = "Account"
            } else {
                cell!.textLabel?.text = "Storage"
            }
        case .Settings:
            switch indexPath.row {
            case 0:
                cell!.textLabel?.text = "Dark theme"
                cell!.accessoryView = themeSwitch
                
            case 1:
                cell!.textLabel?.text = "Show NSFW content"
                cell!.accessoryView = nsfwSwitch
                
            case 2:
                cell!.textLabel?.text = "Type size"
                cell!.detailTextLabel?.text = Settings().typeSize.rawValue
                
            case 3:
                cell!.textLabel?.text = "Video autoplay"
                cell!.detailTextLabel?.text = Settings().videoAutoplay.rawValue
            default:
                break
            }
        case .About:
            cell!.textLabel?.text = "About Reddity"
        }
                
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch Section.init(sec: indexPath.section)! {
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
        case .Settings:
            switch indexPath.row {
            case 3:
                let autoPlayVC: VideoAutoplayViewController = {
                    $0.hidesBottomBarWhenPushed = true
                    $0.modalPresentationStyle = .FullScreen
                    return $0
                }(VideoAutoplayViewController())
                navigationController?.pushViewController(autoPlayVC, animated: true)
            default:
                break
            }
        default:
            break
        }
    }

}
