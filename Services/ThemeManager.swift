//
//  ThemeManager.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

enum CellTheme {
    case dark
    case light

    init?(themeManager: ThemeManager = ThemeManager.defaultManager) {
        self = themeManager.currentTheme == "Default"
            ? .light : .dark
    }

    var backgroundColor: UIColor {
        switch self {
        case .light:
            return UIColor.white
        case .dark:
            return UIColor(colorLiteralRed: 28/255, green: 28/255, blue: 37/255, alpha: 1.0)
        }
    }

    var mainTextColor: UIColor {
        switch self {
        case .light:
            return UIColor.black
        case .dark:
            return UIColor(colorLiteralRed: 79/255, green: 90/255, blue: 119/255, alpha: 1.0)
        }
    }

    var accessoryTextColor: UIColor {
        return FlatBlue()
    }

    var placeholderImageColor: UIColor {
        return UIColor.darkGray
    }
    
    var linkColor: UIColor {
        return UIColor.darkGray
    }
}

enum TableViewTheme {
    case dark
    case light
    
    init?(themeManager: ThemeManager = ThemeManager.defaultManager) {
        self = themeManager.currentTheme == "Default"
            ? .light : .dark
    }

    var backgroundColor: UIColor {
        switch self {
        case .dark:
            return UIColor(colorLiteralRed: 33/255, green: 34/255, blue: 45/255, alpha: 1.0)
        case .light:
            return UIColor(colorLiteralRed: 0.94, green: 0.94, blue: 0.96, alpha: 1.0)
        }
    }

    var separatorColor: UIColor {
        switch self {
        case .dark:
            return UIColor.darkGray
        case .light:
            return UIColor.lightGray
        }
    }

    var indicatorStyle: UIScrollViewIndicatorStyle {
        switch self {
        case .dark:
            return .white
        case .light:
            return .default
        } 
    }
    
    var titleTextColor: UIColor {
        switch self {
        case .dark:
            return UIColor(colorLiteralRed: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        case .light:
            return UIColor(colorLiteralRed: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
        }
    }
}

let kThemeManagerDidChangeThemeNotification = "ThemeManagerDidChangeThemeNotification"

final class ThemeManager: NSObject {
    
    static let defaultManager = ThemeManager()
    
    var currentTheme: String  {
        if let theme = UserDefaults.standard.string(forKey: "AppTheme") {
            return theme
        }
        
        return "Default"
    }
    
    func setTheme(newTheme: String) {
        guard newTheme != currentTheme else {
            return
        }
        
        UserDefaults.standard.set(newTheme, forKey: "AppTheme")
        NotificationCenter.default.post(name: Notification.Name.onThemeChanged, object: nil)
        UIView.transition(with: UIApplication.shared.keyWindow!, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
    
}
