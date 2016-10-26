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
import RxCocoa
#endif
import Moya

protocol TimelineViewModelType {
    var showSpinner: Observable<Bool>! { get }
    var loadNextPageTrigger: Observable<Void>! { get }
    var isRefreshing: Variable<Bool> { get }

    var numberOfLinks: Int { get }
    var updatedContents: Observable<NSDate> { get }
    
    func reload()
    func linkViewModelAtIndexPath(indexPath: NSIndexPath) -> LinkViewModel
}

class TimelineViewModel: NSObject, TimelineViewModelType {
    private let disposeBag = DisposeBag()
    var links = Variable([Link]())

    var isRefreshing = Variable<Bool>(false)

    var numberOfLinks: Int {
        return links.value.count
    }

    var updatedContents: Observable<NSDate> {
        return links
            .asObservable()
            .map { $0.count > 0 }
            .ignore(false)
            .map { _ in NSDate() }
    }
    
    let subreddit: String
    let provider: Networking
    
    var distinctLinks: Observable<[Link]>!
    var showSpinner: Observable<Bool>!
    var loadNextPageTrigger: Observable<Void>!
    
    init(subreddit: String, provider: Networking, loadNextPageTrigger: Observable<Void>) {
        self.subreddit = subreddit
        self.provider = provider
        self.loadNextPageTrigger = loadNextPageTrigger
        
        super.init()
        setup()
    }

    func reload() {
        isRefreshing.value = true
        links.value = []
        recursiveLinkRequest()
            .doOnNext { _ in
                self.isRefreshing.value = false
            }
            .bindTo(links)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Private Methods
    
    private func setup() {
        // start loading upon creation
        recursiveLinkRequest()
            .bindTo(links)
            .addDisposableTo(disposeBag)

        showSpinner = links.asObservable().map { $0.count == 0 }
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
    
    func linkViewModelAtIndexPath(indexPath: NSIndexPath) -> LinkViewModel {
        return links.value[indexPath.item].viewModel    
    }
}
