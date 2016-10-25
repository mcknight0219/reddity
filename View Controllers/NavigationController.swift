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
        self.navigationBar.tintColor = FlatBlue()
        self.navigationBar.titleTextAttributes![NSFontAttributeName] = UIFont(name: "Lato-Regular", size: 20)!
        if ThemeManager.defaultManager.currentTheme == "Default" {
            self.navigationBar.setBackgroundImage(UIImage.imageFilledWithColor(UIColor.whiteColor()), forBarMetrics: .Default)
            if let _ = self.navigationBar.titleTextAttributes {
                self.navigationBar.titleTextAttributes![NSForegroundColorAttributeName] = UIColor(colorLiteralRed: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
            } else {
                self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(colorLiteralRed: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)]
            }
        } else {
            self.navigationBar.setBackgroundImage(UIImage.imageFilledWithColor(UIColor(colorLiteralRed: 28/255, green: 28/255, blue: 37/255, alpha: 1.0)), forBarMetrics: .Default)
            if let _ = self.navigationBar.titleTextAttributes {
                self.navigationBar.titleTextAttributes![NSForegroundColorAttributeName] = UIColor(colorLiteralRed: 79/255, green: 90/255, blue: 119/255, alpha: 1.0)
            } else {
                self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(colorLiteralRed: 79/255, green: 90/255, blue: 119/255, alpha: 1.0)]
            }
        }
        
    }
}
