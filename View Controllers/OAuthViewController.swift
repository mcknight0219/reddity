//
//  OAuthViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-01.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

class OAuthViewController: UIViewController {

    var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(OAuthViewController.cancel))
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "Reddit"
        
        self.webView = UIWebView()
        self.view.addSubview(self.webView)
        webView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.top.bottom.equalTo(self.view)
        }
        
        let request =  NSURLRequest(URL: NSURL(string: "https://www.google.ca")!)
        self.webView.loadRequest(request)
        self.webView.delegate = self
        
        self.webViewDidStartLoad(webView)
    }
    
    func cancel() {
        
    }
}

extension OAuthViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        HUDManager.sharedInstance.showCentralActivityIndicator()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        HUDManager.sharedInstance.hideCentralActivityIndicator()
    }
}
