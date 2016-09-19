//
//  NavigationController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigationController.applyTheme), name: "ThemeManagerDidChangeThemeNotification", object: nil)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return ThemeManager.defaultManager.currentTheme == "Dark" ? .LightContent : .Default
    }

    func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Default" {
            self.navigationBar.setBackgroundImage(UIImage.imageFilledWithColor(UIColor.whiteColor()), forBarMetrics: .Default)
            self.navigationBar.tintColor = FlatOrange()
            if let _ = self.navigationBar.titleTextAttributes {
                self.navigationBar.titleTextAttributes![NSForegroundColorAttributeName] = FlatOrange()
            } else {
                self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: FlatOrange()]
            }
        } else {
            self.navigationBar.setBackgroundImage(UIImage.imageFilledWithColor(UIColor(colorLiteralRed: 32/255, green: 34/255, blue: 34/255, alpha: 1.0)), forBarMetrics: .Default)
            self.navigationBar.tintColor = UIColor.whiteColor()
            if let _ = self.navigationBar.titleTextAttributes {
                self.navigationBar.titleTextAttributes![NSForegroundColorAttributeName] = UIColor.whiteColor()
            } else {
                self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            }
        }
        
    }
}
