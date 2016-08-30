//
//  TabBarController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-02
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyTheme()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.tabBar.barTintColor = FlatBlackDark()
        } else {
            self.tabBar.barTintColor = UIColor.whiteColor()
        }
    }
}
