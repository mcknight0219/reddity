//
//  ThemeManager.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

let kThemeManagerDidChangeThemeNotification = "ThemeManagerDidChangeThemeNotification"

final class ThemeManager: NSObject {
    
    static let sharedInstance = ThemeManager()
    
    var currentTheme: String  {
        
        if let theme = NSUserDefaults.standardUserDefaults().stringForKey("AppTheme") {
            return theme
        }
        
        return "Default"
    }
    
    func setTheme(newTheme: String) {
        guard newTheme != currentTheme else {
            return
        }
        
        NSUserDefaults.standardUserDefaults().setObject(newTheme, forKey: "AppTheme")
        
        NSNotificationCenter.defaultCenter().postNotificationName(kThemeManagerDidChangeThemeNotification, object: nil)
    
        UIView.transitionWithView(UIApplication.sharedApplication().keyWindow!, duration: 0.5, options: .TransitionCrossDissolve, animations: nil, completion: nil)
    }
    
}
