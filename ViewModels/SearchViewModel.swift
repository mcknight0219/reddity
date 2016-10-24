import Foundation
import RxSwift
import Moya

protocol SearchViewModelType {
    var hasHistory: Observable<Bool> { get }
    var selectedScope: Observable<Int>! { get }
    func getSearchResults(query: String) -> Observable<[(Subreddit?, Link?)]>
}

class SearchViewModel: NSObject, SearchViewModelType {
    var selectedScope: Observable<Int>!
    
    var provider: Networking!

    var hasHistory: Observable<Bool> {
        return searchHistory
            .asObservable()
            .map { $0.count == 0 }
    }

    var searchHistory = Variable([String]())

    init(provider: Networking, selectedScope: Observable<Int>) {
        super.init()
        
        self.provider = provider
        self.selectedScope = selectedScope
    }
    
    func getSearchResults(query: String) -> Observable<[(Subreddit?, Link?)]> {
        guard !query.isEmpty else { return Observable.never() }
        
        return selectedScope
            .map { ScopeValues.init(rawValue: $0) }
            .map { scope -> (RedditAPI, ScopeValues) in
                switch scope! {
                case .Title:
                    return (RedditAPI.SearchTitle(query: query, limit: nil, after: nil), .Title)
                case .Subreddit:
                    return (.SearchSubreddit(query: query, limit: nil, after: nil), .Subreddit)
                }
            }
            .map { (endpoint, scope) -> [(Subreddit?, Link?)] in
                return [(nil, nil)]
            }
       
    }



    enum ScopeValues: Int {
        case Title = 0
        case Subreddit

        var name: String {
            switch self {
            case .Title:
                return "Title"
            default:
                return "Subreddit"
            }
        }

        static func allScopeValueNames() -> [String] {
            return [Title, Subreddit].map { $0.name }
        }
    }
}
