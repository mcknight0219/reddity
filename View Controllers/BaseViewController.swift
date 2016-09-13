//
//  BaseViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

/**
 A customized view controller that listens to theme changed notification
 and change its tab bar appearance
 */
class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyTheme()

        NotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseViewController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    } 

    func applyTheme() {
        let tabBarIconColor = ThemeManager.defaultManager.currentTheme == "Dark" ? FlatSkyBlue() : FlatOrange()
        if let barItem = self.tabBarItem {
            switch barItem.tag {
            case 0:
                barItem.image = UIImage.fontAwesomeIconWithName(.Search, textColor: tabBarIconColor, size: CGSizeMake(37, 37))
                break
            case 1:
                barItem.image = UIImage.fontAwesomeIconWithName(.Browse, textColor: tabBarIconColor, size: CGSizeMake(37, 37))
                break
            case 2:
                barItem.image = UIImage.fontAwesomeIconWithName(.List, textColor: tabBarIconColor, size: CGSizeMake(37, 37))
                break
            default:
                barItem.image = UIImage.fontAwesomeIconWithName(.Me, textColor: tabBarIconColor, size: CGSizeMake(37, 37))
            }
        }
    }
}
