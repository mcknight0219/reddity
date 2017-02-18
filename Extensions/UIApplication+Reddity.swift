//
//  UIApplication+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-06.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

extension UIApplication {
    
    // Construct a meaningful user agent sent to reddit
    class func userAgent() -> String {
        let dict = Bundle.main.infoDictionary
        
        let appName = dict!["CFBundleExecutable"]!
        let version = dict!["CFBundleVersion"]!
        
        let deviceModel = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let screenScale = UIScreen.main.scale
        
        return "\(appName)/\(version) \(deviceModel); iOS \(systemVersion); Scale/\(screenScale)"
    }
}

