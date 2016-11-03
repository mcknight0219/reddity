//
//  HUDManager.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-29.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SnapKit
import ChameleonFramework

final class HUDManager {
    static let sharedInstance = HUDManager()
    
    var isShowing = false
    let progressView: UIView
    let bottomView: UIView
    let text: UILabel!

    var timer: NSTimer!
    
    init() {
        progressView = UINib(nibName: "CentralProgressView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! UIView
        let label = progressView.viewWithTag(1) as! UILabel
        label.text = "Loading"
        
        bottomView = {
            $0.frame = CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, 35)
            $0.backgroundColor = UIColor.clearColor()
            $0.clipsToBounds = true
            
            return $0
        }(UIView())
        
        text = {
            $0.textAlignment = .Center
            $0.textColor = UIColor.whiteColor()
            $0.backgroundColor = FlatRed()
            $0.textAlignment = .Center
            
            return $0
        }(UILabel())
        bottomView.addSubview(text)
        
        text.snp_makeConstraints { make in
            make.left.right.bottom.top.equalTo(bottomView)
        }
        
        text.transform = CGAffineTransformMakeTranslation(0, -35)
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
        let win = UIApplication.sharedApplication().keyWindow!
        text.text = title

        win.addSubview(self.bottomView)
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.CurveEaseOut], animations: {
            self.text.transform = CGAffineTransformIdentity
        }, completion: nil)

        self.timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(HUDManager.hideToast), userInfo: nil , repeats: false)
    }

    @objc func hideToast() {
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.CurveEaseOut], animations: {
            self.text.transform = CGAffineTransformMakeTranslation(0, -35)
        }) { finished in
            self.bottomView.removeFromSuperview()
        }

        self.timer.invalidate()
    }
}
