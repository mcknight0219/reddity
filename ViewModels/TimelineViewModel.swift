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
    var loadNextPageTrigger: Observable<Date>! { get }
    var isRefreshing: Variable<Bool> { get }
    var showLoadingFooter: Observable<Bool>! { get }

    var numberOfLinks: Int { get }
    var updatedContents: Observable<Date> { get }
    
    func reload()
    func linkViewModels() -> [LinkViewModel]
    func linkViewModelAtIndexPath(indexPath: IndexPath) -> LinkViewModel
}

class TimelineViewModel: NSObject, TimelineViewModelType {
    private let disposeBag = DisposeBag()
    var links = Variable<[Link]>([])

    var isRefreshing = Variable<Bool>(false)
    
    var showLoadingFooter: Observable<Bool>!

    var numberOfLinks: Int {
        return distinctLinks.value.count
    }

    var updatedContents: Observable<Date> {
        return links
            .asObservable()
            .map {
                $0.count > 0
            }
            .ignore(false)
            .map { _ in
                return Date()
            }
    }
    
    let subreddit: String
    let provider: Networking
    
    var distinctLinks = Variable<[Link]>([])
    var showSpinner: Observable<Bool>!
    var loadNextPageTrigger: Observable<Date>!
    
    init(subreddit: String, provider: Networking, loadNextPageTrigger: Observable<Date>) {
        self.subreddit = subreddit
        self.provider = provider
        self.loadNextPageTrigger = loadNextPageTrigger
        
        super.init()
        setup()
    }

    func reload() {
        isRefreshing.value = true
        
        recursiveLinkRequest()
            .takeUntil(rx.deallocated)
            .do(onNext: { _ in
                self.isRefreshing.value = false
            })
            .bindTo(links)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Private Methods
    
    private func setup() {
        // start loading upon creation
        recursiveLinkRequest()
            .takeUntil(rx.deallocated)
            .bindTo(links)
            .addDisposableTo(disposeBag)
        
        links
            .asObservable()
            .distinctUntilChanged { (lhs, rhs) -> Bool in
                return lhs.count == rhs.count
            }
            .bindTo(distinctLinks)
            .addDisposableTo(disposeBag)

        showSpinner = Observable.combineLatest(distinctLinks.asObservable(), isRefreshing.asObservable(), reachabilityManager.reach) { (o1, o2, o3) in
            return o1.count == 0 && !o2 && o3
        }
        
        showLoadingFooter =
            Observable
                .combineLatest(loadNextPageTrigger, updatedContents) {
                    $0.1.compare($0.0) == .orderedAscending
                }
    }
    
    private func recursiveLinkRequest() -> Observable<[Link]> {
        return linkRequest(loadedSoFar: [], after: "", loadNextPageTrigger: self.loadNextPageTrigger)
    }
    
    private func linkRequest(loadedSoFar: [Link], after: String, loadNextPageTrigger: Observable<Date>) -> Observable<[Link]> {
        let endpoint = self.subreddit.isEmpty
            ? RedditAPI.FrontPage(after: after)
            : RedditAPI.Subreddit(name: self.subreddit, after: after)
        
        return self.provider.request(action: endpoint)
            .filterSuccessfulStatusCodes()
            .flatMap { response -> Observable<[Link]> in
                
                let jsonObject = JSON(data: response.data)
                let afterName = jsonObject["data"]["after"].string ?? ""
                let newLinks = linkParser(json: jsonObject)
                let updatedLinks = loadedSoFar + newLinks
                
                return Observable.just(updatedLinks)
                    .concat(Observable.never().takeUntil(loadNextPageTrigger))
                    .concat(self.linkRequest(loadedSoFar: updatedLinks, after: afterName, loadNextPageTrigger: loadNextPageTrigger))
            }
    }
    
    func linkViewModelAtIndexPath(indexPath: IndexPath) -> LinkViewModel {
        return distinctLinks.value[indexPath.item].viewModel
    }

    func linkViewModels() -> [LinkViewModel] {
        return distinctLinks.value.map { $0.viewModel }
    }
    
    func clear() {
        self.links.value.removeAll()
    }
}
