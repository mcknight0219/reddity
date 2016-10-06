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

    let bottomView: UIView
    
    init() {
        progressView = UINib(nibName: "CentralProgressView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! UIView
        let label = progressView.viewWithTag(1) as! UILabel
        label.text = "Loading"
        
        bottomView = {
            $0.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 120, UIScreen.mainScreen().bounds.width, 120)
            $0.transform = CGAffineTransformMakeTranslation(0, 120)
            $0.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.7)
            let label = {
                $0.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 80)
                $0.textAlignment = .Center
                $0.numberOflines = 1
            }(UILabel())
            $0.addSubview(label)
            label.frame.center = $0.center
        }(UIView())
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

    func showToast(withTitle title: String) {
        let win = UIApplication.sharedApplication().keyWindow
        let label = self.bottomView.subViews[0] as! UILabel
        label.text = title

        win.addSubview(self.bottomView)
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.CurveEaseOut], animation: {
            self.bottomView.transform = CGAffineTransformIdentity
        }, completion: nil)
    }

    func hideToast() {
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.CurveEaseOut], animation: {
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, 50)
        }) { finished in
            self.bottomView.removeFromSuperView()
            self.bottomView.transform = CGAffineTransformIdentity
        }
    }
}
