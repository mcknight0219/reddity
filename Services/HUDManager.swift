//
//  HUDManager.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-29.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

final class HUDManager {
    
    static let sharedInstance = HUDManager()
    
    var isShowing = false
    
    let progressView: UIView
    
    init() {
        progressView = UINib(nibName: "CentralProgressView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! UIView
        let label = progressView.viewWithTag(1) as! UILabel
        label.text = "Loading"
        
    }
    
    func showCentralActivityIndicator() {
        guard !self.isShowing else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate, let window = appDelegate.window {
                self.progressView.frame = CGRectMake((window.frame.width - 160) / 2, (window.frame.height - 100) / 2, 160, 100)
                self.progressView.alpha = 0
                
                window.addSubview(self.progressView)
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                
                UIView.animateWithDuration(0.2) {
                    self.progressView.alpha = 1
                    self.isShowing = true
                }
            }
        }
    }
    
    func hideCentralActivityIndicator() {
        guard self.isShowing else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.4, animations: {
                self.progressView.alpha = 0
            }) { (finished) in
                self.progressView.removeFromSuperview()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
        }
        
        self.isShowing = false
    }
}
