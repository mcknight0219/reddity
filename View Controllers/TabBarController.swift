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

        NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.applyTheme), name: Notification.Name.onThemeChanged, object: nil)
    }

    func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.tabBar.barTintColor = UIColor(colorLiteralRed: 28/255, green: 28/255, blue: 37/255, alpha: 1.0)
        } else {
            self.tabBar.barTintColor = UIColor.white
        }
    }
}
