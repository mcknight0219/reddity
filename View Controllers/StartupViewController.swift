//
//  StartupViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-01.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SafariServices
import SnapKit
import ChameleonFramework

final class StartupViewController: UIViewController {
    
    var logo: UIImageView!
    var loginButton: UIButton!
    var skipButton: UIButton!

    var oAuthCompleteAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.makeUI()
        self.loginButton.addTarget(self, action: #selector(StartupViewController.login), forControlEvents: .TouchDown)
        self.skipButton.addTarget(self, action: #selector(StartupViewController.skip), forControlEvents: .TouchDown)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StartupViewController.postOAuth(_:)), name: "OAuthFinishedNotification", object: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        print("Deallocating startup view controller")
    }
    
    func makeUI() {
        self.view.backgroundColor = UIColor.whiteColor()
        
        logo = UIImageView(image: UIImage(named: "logo"))
        logo.contentMode = .ScaleAspectFit
        
        self.view.addSubview(logo)
        logo.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(80)
            make.height.equalTo(75)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
        }
        
        loginButton = UIButton()
        loginButton.setTitle("Log In", forState: .Normal)
        loginButton.setTitleColor(FlatWhite(), forState: .Normal)
        loginButton.titleLabel?.font = UIFont(name: "Lato-Bold", size: 18)
        loginButton.titleEdgeInsets = UIEdgeInsetsMake(5, 7, 5, 7)
        loginButton.backgroundColor = FlatOrange()
        loginButton.tintColor = FlatWhite()
        loginButton.layer.cornerRadius = 20
        loginButton.layer.borderWidth = 0.8
        loginButton.layer.borderColor = FlatWhite().CGColor
        
        self.view.addSubview(loginButton)
        loginButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(-250)
            make.leading.equalTo(30)
            make.height.equalTo(45)
            make.trailing.equalTo(-30)
        }
        
        loginButton.canBecomeFirstResponder()
        
        skipButton = UIButton()
        skipButton.setTitle("Skip", forState: .Normal)
        skipButton.setTitleColor(FlatOrange(), forState: .Normal)
        skipButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 18)
        skipButton.tintColor = FlatOrange()
        skipButton.layer.cornerRadius = 20
        skipButton.layer.borderWidth = 0.8
        skipButton.layer.borderColor = FlatOrange().CGColor
        
        self.view.addSubview(skipButton)
        skipButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.loginButton.snp_bottom).offset(15)
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
            make.height.equalTo(45)
        }

    }
    
    func skip() {
        NSNotificationCenter.defaultCenter().postNotificationName("PushInTabBarAfterStartup", object: nil)
    }
    
    func login() {
        let authUrl = NSURL(string: "https://ssl.reddit.com/api/v1/authorize.compact?client_id=oJcxJfNvAUDpOQ&response_type=code&state=TEST&redirect_uri=reddity://response&duration=permanent&scope=identity,subscribe,mysubreddits,read".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
        let safariViewController = SFSafariViewController(URL: authUrl!)
        self.presentViewController(safariViewController, animated: true, completion: nil)
        
        self.oAuthCompleteAction = {
            safariViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension StartupViewController {
    func postOAuth(notification: NSNotification) {
        self.oAuthCompleteAction?()
        
        if let number = notification.object as? NSNumber {
            switch number.intValue {
            case 1:
                NSNotificationCenter.defaultCenter().postNotificationName("PushInTabBarAfterStartup", object: nil)
            default:
                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    let alertController = UIAlertController(title: "Sorry", message: "Access denied to user account. You can try log in later in Settings", preferredStyle: .Alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .Default) { action in
                        
                    }
                    
                    alertController.addAction(action)
                    self!.presentViewController(alertController, animated: true, completion: nil)
                    alertController.view.tintColor = FlatOrange()
                }
            }
        }
        
    }
}
