//
//  BaseViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

/**
 A customized view controller that listens to theme changed notification
 and change its tab bar appearance
 */
class BaseViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reachabilityManager.reach
            .subscribeNext { connected in
                let hud = HUDManager.sharedInstance
                if !connected {
                    hud.showToast(withTitle: "No Internet Connection.")
                }             
            }
            .addDisposableTo(disposeBag)
    } 
}
