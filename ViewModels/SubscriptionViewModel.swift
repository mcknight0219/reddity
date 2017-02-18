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
    var showRefresh: Variable<Bool> { get }

    func displayNameAtIndexPath(indexPath: IndexPath) -> String
    // Human readable format
    func subscribersAtIndexPath(indexPath: IndexPath) -> String
    func unsubscribe(indexPath: IndexPath)
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
    var showRefresh = Variable<Bool>(false)

    fileprivate let disposeBag = DisposeBag()
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
        .request(action: RedditAPI.Subscriptions)
        .filterSuccessfulStatusCodes()
        .do(onNext: { _ in
            self.showRefresh.value = false
        })
        .flatMap { response -> Observable<[Subreddit]> in
            let jsonObject = JSON(data: response.data)
            let subs = subredditsParser(json: jsonObject)
            return Observable.just(subs)
        }
        .bindTo(subs)
        .addDisposableTo(disposeBag)
    }
    
    private func reloadSubscriptions() {
        self.provider
            .request(action: RedditAPI.Subscriptions)
            .filterSuccessfulStatusCodes()
            .flatMap { response -> Observable<[Subreddit]> in
                
                let jsonObject = JSON(data: response.data)
                let subs = subredditsParser(json: jsonObject)
                return Observable.just(subs)
            }
            .bindTo(subs)
            .addDisposableTo(disposeBag)
    }

    private func setup() {
        
        self.provider
            .request(action: RedditAPI.Subscriptions)
            .filterSuccessfulStatusCodes()
            .takeUntil(rx.deallocated)
            .map { response -> [Subreddit] in
                let jsonObject = JSON(data: response.data)
                let subs = subredditsParser(json: jsonObject)
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
                    let sorted = order!.sortedSubscription(subscription: me.subs.value)
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
        case alphabetical = 0
        case popularity
        case favorite

        var name: String {
            switch self {
            case .alphabetical:
                return "Alphabetical"
            case .popularity:
                return "Popularity"
            case .favorite:
                return "Favorite"
            }
        }

        func sortedSubscription(subscription: [Subreddit]) -> [Subreddit] {
            switch self {
            case .alphabetical:
                return subscription.sorted {
                    $0.displayName.compare($1.displayName) == .orderedAscending
                }
            case .popularity:
                return subscription.sorted {
                    return $0.subscribers > $1.subscribers
                }
            case .favorite:
                // TODO: depend on database
                return subscription
            }
        }
    }
}

extension SubscriptionViewModel {
    func displayNameAtIndexPath(indexPath: IndexPath) -> String {
        let sub = sortedSubs.value[indexPath.row]
        return sub.displayName
    }

    func subscribersAtIndexPath(indexPath: IndexPath) -> String {
        let n = Double(sortedSubs.value[indexPath.row].subscribers)
        if n >= 1.0e6 {
            return String(format: "%.1fM", n / 1e6)
        } else if n >= 1.0e3 {
            return String(format: "%.1fK", n / 1e3)
        } else {
            return String(n)
        }
    }

    func unsubscribe(indexPath: IndexPath) {
        self.provider.request(action: .Unsubscribe(name: displayNameAtIndexPath(indexPath: indexPath)))
            .filterSuccessfulStatusCodes()
            .do(onNext: { _ in
                let subs = self.subs.value
                self.subs.value = subs.filter {
                    $0.id != self.sortedSubs.value[indexPath.row].id
                }
                
                print("\(self.subs.value.count)")
            })
            .subscribe(onNext: { _ in
                
            })
            .addDisposableTo(disposeBag)
    }
}

