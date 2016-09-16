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

        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseViewController.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    } 

    func applyTheme() {
        
    }
}
