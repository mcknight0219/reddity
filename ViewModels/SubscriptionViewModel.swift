import Foundation
import SwiftyJSON
#if !RX_NO_MODULE
import RxSwift
#endif

protocol SubscriptionViewModelType {

    var numberOfSubscriptions: Int { get }
    var updatedContents: Observable<NSDate> { get }
    var selectedOrder: Observable<Int> { get }
    var showBackground: Observable<Bool>! { get }

    func subredditModelAtIndexPath(indexPath: NSIndexPath) -> Subreddit
}

class SubscriptionViewModel: NSObject, SubscriptionViewModelType {
    
    let provider: Networking!
    var subs = Variable<[Subreddit]>([])
    // We could sort subscriptions if necessary
    var sortedSubs = Variable<[Subreddit]>([])

    var selectedOrder: Observable<Int>
    
    var numberOfSubscriptions: Int {
        return sortedSubs.value.count
    }
    
    var updatedContents: Observable<NSDate> {
        return sortedSubs
            .asObservable()
            .map { $0.count > 0 }
            .ignore(false)
            .map { _ in NSDate() }
    }

    var showBackground: Observable<Bool>!
    
    private let disposeBag = DisposeBag()
    init(provider: Networking, selectedOrder: Observable<Int>) {
        // Get subscription from API
        self.provider = provider
        self.selectedOrder = selectedOrder
        super.init()
        
        self.setup()
    }

    private func setup() {
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
                    return order!.sortedSubscription(me.subs.value)
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
                    $0.title.compare($1.title) == .OrderedAscending
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
}

