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
        webView = WKWebView(frame: CGRect.zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.postSignIn), name: Notification.Name.onOAuthFinished, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sign In"

        let signInURL: URL = URL(string: "https://ssl.reddit.com/api/v1/authorize.compact?client_id=oJcxJfNvAUDpOQ&response_type=code&state=TEST&redirect_uri=reddity://response&duration=permanent&scope=identity,subscribe,mysubreddits,read".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        let request = URLRequest(url: signInURL)
        webView.load(request)
        
    }
    
    @objc func postSignIn(notification: NSNotification) {
        if let number = notification.object as? NSNumber {
            if number == 1 {
                _ = navigationController?.popViewController(animated: true)
            } else {
                
            }
        }
    }
}

extension SignInViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let URL = navigationAction.request.url {
            if URL.scheme == "reddity" {
                let app = UIApplication.shared
                app.openURL(URL)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}


