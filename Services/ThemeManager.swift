//
//  ThemeManager.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

enum CellTheme {
    case Dark
    case Light

    init?(themeManager: ThemeManager = ThemeManager.defaultManager) {
        self = themeManager.currentTheme == "Default"
            ? Light : Dark
    }

    var backgroundColor: UIColor {
        switch self {
        case Light: 
            return UIColor.whiteColor()
        case Dark:
            return UIColor(colorLiteralRed: 28/255, green: 28/255, blue: 37/255, alpha: 1.0)
        }
    }

    var mainTextColor: UIColor {
        switch self {
        case Light:
            return UIColor.blackColor()
        case Dark:
            return UIColor(colorLiteralRed: 79/255, green: 90/255, blue: 119/255, alpha: 1.0)
        }
    }

    var accessoryTextColor: UIColor {
        return UIColor.lightGrayColor()
    }

    var placeholderImageColor: UIColor {
        return UIColor.darkGrayColor()
    }
}

enum TableViewTheme {
    case Dark
    case Light

    var backgroundColor: UIColor {
        switch self {
        case Dark:
            return UIColor(colorLiteralRed: 33/255, green: 34/255, blue: 45/255, alpha: 1.0)
        case Light:
            return UIColor(colorLiteralRed: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
        }
    }

    var separatorColor: UIColor {
        switch self {
        case Dark:
            return UIColor.darkGrayColor()
        case Light:
            return UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.01, alpha: 1.0)
        }
    }

    var indicatorStyle: UIScrollViewIndicatorStyle {
        switch self {
        case Dark:
            return .White
        case Light:
            return .Default
        } 
    }
}

let kThemeManagerDidChangeThemeNotification = "ThemeManagerDidChangeThemeNotification"

final class ThemeManager: NSObject {
    
    static let defaultManager = ThemeManager()
    
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
