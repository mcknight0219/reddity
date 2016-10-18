//
//  ReachabilityManager.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-04.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import RxSwift
import Reachability
import Moya

class ReachabilityManager: NSObject {
    let _reach = ReplaySubject<Bool>.create(bufferSize: 1)
    var reach: Observable<Bool> {
        return _reach.asObservable()
    }
    
    private let reachability = Reachability.reachabilityForInternetConnection()
    
    override init() {
        super.init()
        
        reachability.reachableBlock = { [weak self] _ in
            dispatch_async(dispatch_get_main_queue()) {
                self?._reach.onNext(true)
            }
        }
        
        reachability.unreachableBlock = { [weak self] _ in
            dispatch_async(dispatch_get_main_queue()) {
                self?._reach.onNext(false)
            }
        }
        
        reachability.startNotifier()
        _reach.onNext(reachability.isReachable())
    }
}

