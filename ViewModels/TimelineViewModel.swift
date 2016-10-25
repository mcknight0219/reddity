//
//  TimelineViewModel.swift
//  Reddity
//
//  Created by Qiang Guo on 2016/10/22.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import Foundation
import SwiftyJSON
#if !RX_NO_MODULE
import RxSwift
#endif
import Moya

protocol TimelineViewModelType {
    var showSpinner: Observable<Bool>! { get }
    var loadNextPageTrigger: Observable<Void>! { get }
    var reloadTrigger: Observable<Void>! { get }
}

class TimelineViewModel: NSObject, TimelineViewModelType {
    private let disposeBag = DisposeBag()
    private var links = Variable([Link]())
    
    let subreddit: String
    let provider: Networking
    
    var showSpinner: Observable<Bool>!
    var showRefreshing: Observable<Bool>!
    
    var loadNextPageTrigger: Observable<Void>!
    var reloadTrigger: Observable<Void>!
    
    init(subreddit: String, provider: Networking, loadNextPageTrigger: Observable<Void>, reloadTrigger: Observable<Void>) {
        self.subreddit = subreddit
        self.provider = provider
        self.loadNextPageTrigger = loadNextPageTrigger
        self.reloadTrigger = reloadTrigger
        
        super.init()
        setup()
    }
    
    // MARK: Private Methods
    
    private func setup() {
        
        let loading = recursiveLinkRequest().takeUntil(reloadTrigger)
        
        showSpinner = links.asObservable().map { $0.count == 0 }
        
        reloadTrigger
            .subscribeNext() { _ in
                self.links = Variable([Link]())
                loading
                    .bindTo(self.links)
                    .addDisposableTo(self.disposeBag)
            }
            .addDisposableTo(disposeBag)
        
        loading
            .bindTo(links)
            .addDisposableTo(disposeBag)
    }
    
    private func recursiveLinkRequest() -> Observable<[Link]> {
        return linkRequest([], after: "", loadNextPageTrigger: self.loadNextPageTrigger)
            .startWith([])
    }
    
    private func linkRequest(loadedSoFar: [Link], after: String, loadNextPageTrigger: Observable<Void>) -> Observable<[Link]> {
        return self.provider.request(.Subreddit(name: self.subreddit, after: after))
            .filterSuccessfulStatusCodes()
            .flatMap { response -> Observable<[Link]> in
                
                let jsonObject = JSON(data: response.data)
                let afterName = jsonObject["data"]["after"].string ?? ""
                let newLinks = linkParser(jsonObject)
                let updatedLinks = loadedSoFar + newLinks
                
                return Observable.just(updatedLinks)
                    .concat(Observable.never().takeUntil(loadNextPageTrigger))
                    .concat(self.linkRequest(updatedLinks, after: afterName, loadNextPageTrigger: loadNextPageTrigger))
            }
    }
    
    
}
