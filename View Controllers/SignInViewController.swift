//
//  SignInViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2017/1/28.
//  Copyright © 2017年 Qiang Guo. All rights reserved.
//

import UIKit
import WebKit

class SignInViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRectZero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.postSignIn(_:)), name: "OAuthFinishedNotification", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sign In"

        let signInURL = NSURL(string: "https://ssl.reddit.com/api/v1/authorize.compact?client_id=oJcxJfNvAUDpOQ&response_type=code&state=TEST&redirect_uri=reddity://response&duration=permanent&scope=identity,subscribe,mysubreddits,read".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)!
        let request = NSURLRequest(URL: signInURL)
        webView.loadRequest(request)
        
    }
    
    @objc func postSignIn(notification: NSNotification) {
        if let number = notification.object as? NSNumber {
            if number == 1 {
                navigationController?.popViewControllerAnimated(true)
            } else {
                
            }
        }
    }
}

extension SignInViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let URL = navigationAction.request.URL {
            if URL.scheme == "reddity" {
                let app = UIApplication.sharedApplication()
                app.openURL(URL)
                decisionHandler(.Cancel)
                return
            }
            decisionHandler(.Allow)
        }
    }
}


