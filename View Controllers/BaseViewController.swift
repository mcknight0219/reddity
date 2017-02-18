//
//  BaseViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

/**
 A customized view controller that listens to theme changed notification
 and change its tab bar appearance
 */
class BaseViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachabilityManager.reach
            .subscribe(onNext: { connected in
                if !connected {
                    SVProgressHUD.showError(withStatus: "No Internet Connection")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                }             
            })
            .addDisposableTo(disposeBag)
    } 
}
