import Foundation
import SwiftyJSON
#if !RX_NO_MODULE
import RxSwift
#endif

protocol SubscriptionViewModelType {

    var numberOfSubscriptions: Int { get }
    var updatedContents: Observable<Int> { get }
    var selectedOrder: Observable<Int> { get }
    var showBackground: Observable<Bool>! { get }
    var showRefresh: Observable<Bool>! { get }

    func subredditModelAtIndexPath(indexPath: NSIndexPath) -> Subreddit
    func unsubscribe(indexPath: NSIndexPath)
    func reload()
}

class SubscriptionViewModel: NSObject, SubscriptionViewModelType {
    
    let provider: Networking!
    var subs = Variable([Subreddit]())
    var sortedSubs = Variable<[Subreddit]>([])

    var selectedOrder: Observable<Int>
    
    var numberOfSubscriptions: Int {
        return self.sortedSubs.value.count
    }
    
    var updatedContents: Observable<Int> {
        return sortedSubs
            .asObservable()
            .map { subs in
                return subs.count
            }
    }

    var showBackground: Observable<Bool>!
    var showRefresh = Observable<Bool>(false)

    private let disposeBag = DisposeBag()
    init(provider: Networking, selectedOrder: Observable<Int>) {
        // Get subscription from API
        self.provider = provider
        self.selectedOrder = selectedOrder
        
        super.init()
        self.setup()
    }

    func reload() {
        showRefresh.value = true
        
        self.provider
        .request(RedditAPI.Subscriptions)
        .filterSuccessfulStatusCodes()
        .doOn { _ in 
            self.showRefresh.value = false
        }
        .flatMap { response -> Observable<[Subreddit]> in
            let jsonObject = JSON(data: response.data)
            let subs = subredditsParser(jsonObject)
            return Observable.just(subs)
        }
        .bindTo(subs)
        .addDisposableTo(disposeBag)
    }
    
    private func reloadSubscriptions() {
        self.provider
            .request(RedditAPI.Subscriptions)
            .filterSuccessfulStatusCodes()
            .flatMap { response -> Observable<[Subreddit]> in
                
                let jsonObject = JSON(data: response.data)
                let subs = subredditsParser(jsonObject)
                return Observable.just(subs)
            }
            .bindTo(subs)
            .addDisposableTo(disposeBag)
    }

    private func setup() {
        self.reload
            .subscribeNext { _ in
                self.reloadSubscriptions()
            }
            .addDisposableTo(disposeBag)
        
        self.provider
            .request(RedditAPI.Subscriptions)
            .filterSuccessfulStatusCodes()
            .takeUntil(rx_deallocated)
            .map { response -> [Subreddit] in
                let jsonObject = JSON(data: response.data)
                let subs = subredditsParser(jsonObject)
                return subs
            }
            .bindTo(subs)
            .addDisposableTo(disposeBag)

        // combineLatest expects arguments of same type
        let distinctSubs = subs
            .asObservable()
            .distinctUntilChanged {
                $0 == $1
            }
            .map { _ in
                return 0
            }
        
        Observable
            .combineLatest(selectedOrder, distinctSubs) { ints -> Int in
                return ints.0
            }
            .map { index in
                SortOrder.init(rawValue: index)
            }
            .map { [weak self] order in
                if let me = self {
                    let sorted = order!.sortedSubscription(me.subs.value)
                    return sorted
                } else {
                    return []
                }
            }
            .bindTo(sortedSubs)
            .addDisposableTo(disposeBag)
        
        showBackground = subs
            .asObservable()
            .map { $0.count == 0 }
            .startWith(false)
    }

    enum SortOrder: Int {
        case Alphabetical = 0
        case Popularity
        case Favorite

        var name: String {
            switch self {
            case Alphabetical:
                return "Alphabetical"
            case Popularity:
                return "Popularity"
            case Favorite:
                return "Favorite"
            }
        }

        func sortedSubscription(subscription: [Subreddit]) -> [Subreddit] {
            switch self {
            case Alphabetical:
                return subscription.sort {
                    $0.displayName.compare($1.displayName) == .OrderedAscending
                }
            case Popularity:
                return subscription.sort {
                    return $0.subscribers > $1.subscribers
                }
            case Favorite:
                // TODO: depend on database
                return subscription
            }
        }
    }
}

extension SubscriptionViewModel {
    func subredditModelAtIndexPath(indexPath: NSIndexPath) -> Subreddit {
        return sortedSubs.value[indexPath.row]
    }
    
    func unsubscribe(indexPath: NSIndexPath) {
        self.provider.request(.Unsubscribe(name: subredditModelAtIndexPath(indexPath).name))
            .filterSuccessfulStatusCodes()
            .doOn { _ in
                let subs = self.subs.value
                self.subs.value = subs.filter {
                    $0.id != self.sortedSubs.value[indexPath.row].id
                }
                
                print("\(self.subs.value.count)")
            }
            .subscribeNext { _ in
                
            }
            .addDisposableTo(disposeBag)
    }
}

