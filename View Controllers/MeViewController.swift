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
            $0.onTintColor = UIColor.green
            return $0
        }(UISwitch())
        
        self.nsfwSwitch = {
            $0.onTintColor = UIColor.green
            return $0
        }(UISwitch())
        
        let darkThemeOn = Variable(Settings().theme == .Dark)
        (themeSwitch.rx.value <-> darkThemeOn).addDisposableTo(disposeBag)
        
        darkThemeOn
            .asObservable()
            .subscribe(onNext: { x in
                ThemeManager.defaultManager.setTheme(newTheme: x ? "Dark" : "Default")
            })
            .addDisposableTo(disposeBag)
        
        let nsfwOn = Variable(true)
        (nsfwSwitch.rx.value <-> nsfwOn).addDisposableTo(disposeBag)
        nsfwOn.asObservable()
            .subscribe(onNext: { _ in
            })
            .addDisposableTo(disposeBag)
    }

    enum Section: Int {
        case accountAndStorage = 0
        case settings
        case about

        init?(sec: Int) {
            switch sec {
            case 0:
                self = .accountAndStorage
            case 1:
                self = .settings
            case 2:
                self = .about
            default:
                return nil
            }
        }

        static func numberOfSections() -> Int {
            return 3
        }

        var numberOfRows: Int {
            switch self {
            case .accountAndStorage:
                return 2
            case .settings:
                return 4
            case .about:
                return 1
            }
        }

        var title: String {
            switch self {
            case .accountAndStorage:
                return ""
            case .settings:
                return "General"
            case .about:
                return ""
            }
        }
        
        var height: CGFloat {
            switch self {
            case .settings:
                return 50
            default:
                return 40
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.init(sec: section)!.numberOfRows
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sec = Section.init(sec: section)!
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: sec.height))
        view.backgroundColor = UIColor.clear
        
        let sep = UIView(frame: CGRect(x: 0, y: view.frame.size.height-0.5, width: view.frame.size.width, height: 0.5))
        sep.backgroundColor = UIColor(colorLiteralRed: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        view.addSubview(sep)
        
        if case .settings = sec {
            let titleLabel = UILabel(frame: CGRect(x: 15, y: 20, width: tableView.frame.size.width, height: 40))
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.text = sec.title
            titleLabel.font = UIFont.systemFont(ofSize: 15)
            
            view.addSubview(titleLabel)
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Section.init(sec: section)!.height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "SettingCell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "SettingCell")
        }
        // Common cell settings
        cell!.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell!.accessoryType = .disclosureIndicator

        switch Section.init(sec: indexPath.section)! {
        case .accountAndStorage:
            if indexPath.row == 0 {
                cell!.textLabel?.text = "Account"
            } else {
                cell!.textLabel?.text = "Storage"
            }
        case .settings:
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
        case .about:
            cell!.textLabel?.text = "About Reddity"
        }
                
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section.init(sec: indexPath.section)! {
        case .accountAndStorage:
            switch indexPath.row {
            case 0:
                let accountVC: AccountViewController = {
                    $0.hidesBottomBarWhenPushed = true
                    $0.modalPresentationStyle = .fullScreen
                    return $0
                }(AccountViewController())
                navigationController?.pushViewController(accountVC, animated: true)
            case 1:
                let storageVC: StorageViewController = {
                    $0.hidesBottomBarWhenPushed = true
                    $0.modalPresentationStyle = .fullScreen
                    return $0
                }(StorageViewController())
                navigationController?.pushViewController(storageVC, animated: true)
            default:
                break
            }
        case .settings:
            switch indexPath.row {
            case 3:
                let autoPlayVC: VideoAutoplayViewController = {
                    $0.hidesBottomBarWhenPushed = true
                    $0.modalPresentationStyle = .fullScreen
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
