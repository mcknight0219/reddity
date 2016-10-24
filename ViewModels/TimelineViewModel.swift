//
//  TimelineViewModel.swift
//  Reddity
//
//  Created by Qiang Guo on 2016/10/22.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
import Moya

protocol TimelineViewModelType {
    var showSpinner: Observable<Bool>! { get }
    var fetchNextPage: Observable<Void>! { get }
}

class TimelineViewModel: NSObject, TimelineViewModelType {
    
    private var links = Variable([Link]())
    
    let subreddit: String
    let provider: Networking
    
    var showSpinner: Observable<Bool>!
    var fetchNextPage: Observable<Void>!
    
    init(subreddit: String, provider: Networking, fetchNextPage: Observable<Void>) {
        self.subreddit = subreddit
        self.provider = provider
        self.fetchNextPage = fetchNextPage
        
        super.init()
        setup()
    }
    
    // MARK: Private Methods
    
    private func setup() {
        showSpinner = links.asObservable().map { $0.count == 0 }
        
    }
    
    
}
