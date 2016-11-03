import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

protocol SubscriptionViewModelType {

}

class SubscriptionViewModel: NSObject {
    
    let provider: Networking!
    var subs: Variable<[Link]>([])     
    // We could sort subscriptions if necessary
    var sortedSubs: Variable<[Link]>([]) 

    private let disposeBag = DisposeBag()
    init(provider: Networking) {
        // Get subscription from API
        self.provider = provider
        getSubscriptions()
    }

    private func getSubscriptions() {
        self.provider
            .request(RedditAPI.Subscriptions)
            .filterSuccessfulStatusCodes()
            .flatMap { response -> Observable<[Link]> in
            }
            .bindTo(subs)
            .addDisposableTo(disposeBag)
    }
}

