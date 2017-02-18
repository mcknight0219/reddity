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
        self.loginButton.addTarget(self, action: #selector(StartupViewController.login), for: .touchDown)
        self.skipButton.addTarget(self, action: #selector(StartupViewController.skip), for: .touchDown)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StartupViewController.postOAuth), name: Notification.Name.onOAuthFinished, object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        print("Deallocating startup view controller")
    }
    
    func makeUI() {
        self.view.backgroundColor = UIColor.white
()
        logo = UIImageView(image: UIImage(named: "logo"))
        logo.contentMode = .scaleAspectFit
        
        self.view.addSubview(logo)
        logo.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(80)
            make.height.equalTo(75)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
        }
        
        loginButton = UIButton()
        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(FlatWhite(), for: .normal)
        loginButton.titleLabel?.font = UIFont(name: "Lato-Bold", size: 18)
        loginButton.titleEdgeInsets = UIEdgeInsetsMake(5, 7, 5, 7)
        loginButton.backgroundColor = FlatOrange()
        loginButton.tintColor = FlatWhite()
        loginButton.layer.cornerRadius = 20
        loginButton.layer.borderWidth = 0.8
        loginButton.layer.borderColor = FlatWhite().cgColor
        
        self.view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(-250)
            make.leading.equalTo(30)
            make.height.equalTo(45)
            make.trailing.equalTo(-30)
        }
        
        loginButton.becomeFirstResponder()
        
        skipButton = UIButton()
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(FlatOrange(), for: .normal)
        skipButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 18)
        skipButton.tintColor = FlatOrange()
        skipButton.layer.cornerRadius = 20
        skipButton.layer.borderWidth = 0.8
        skipButton.layer.borderColor = FlatOrange().cgColor
        
        self.view.addSubview(skipButton)
        skipButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.loginButton.snp.bottom).offset(15)
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
            make.height.equalTo(45)
        }

    }
    
    func skip() {
        NotificationCenter.default.post(name: Notification.Name.onAfterStartup, object: nil)
    }
    
    func login() {
        let urlStr = "https://ssl.reddit.com/api/v1/authorize.compact?client_id=oJcxJfNvAUDpOQ&response_type=code&state=TEST&redirect_uri=reddity://response&duration=permanent&scope=identity,subscribe,mysubreddits,read".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let authUrl = URL(string: urlStr!)
        let safariViewController = SFSafariViewController(url: authUrl!)
        self.present(safariViewController, animated: true, completion: nil)
        
        self.oAuthCompleteAction = {
            safariViewController.dismiss(animated: true, completion: nil)
        }
    }
}

extension StartupViewController {
    func postOAuth(notification: NSNotification) {
        self.oAuthCompleteAction?()
        
        if let number = notification.object as? NSNumber {
            switch number.intValue {
            case 1:
                NotificationCenter.default.post(name: Notification.Name.onAfterStartup, object: nil)
            default:
                DispatchQueue.main.async { [weak self] in
                    let alertController = UIAlertController(title: "Sorry", message: "Access denied to user account. You can try log in later in Settings", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .default) { action in
                        
                    }
                    
                    alertController.addAction(action)
                    self!.present(alertController, animated: true, completion: nil)
                    alertController.view.tintColor = FlatOrange()
                }
            }
        }
        
    }
}
