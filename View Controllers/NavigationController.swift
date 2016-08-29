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
        
        return ThemeManager.sharedInstance.currentTheme == "Dark" ? .LightContent : .Default
    
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func applyTheme() {
        if ThemeManager.sharedInstance.currentTheme == "Default" {
        self.navigationBar.setBackgroundImage(UIImage.imageFilledWithColor(UIColor.whiteColor()), forBarMetrics: .Default)
            self.navigationBar.tintColor = FlatOrange()
            self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: FlatOrange()]
            
        } else {
            
            self.navigationBar.setBackgroundImage(UIImage.imageFilledWithColor(FlatBlack()), forBarMetrics: .Default)
            self.navigationBar.tintColor = FlatNavyBlueDark()
            self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: FlatNavyBlue()]
        }
        
    }
}
