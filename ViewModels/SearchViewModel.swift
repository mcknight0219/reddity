import Foundation
import RxSwift
import Moya

protocol SearchViewModelType {
    var hasHistory: Observable<Bool>
    func getSearchResults(_ query: String) -> Observable<[(Subreddit?, Link?)]>
}

class SearchViewModel: NSObject, SearchViewModelType {
    var selectedScope: Observable<ScopeValues>!
    var provider: Networking!

    var hasHistory: Observable<Bool> {
        return searchHistory
            .asObservable()
            .map { $0.count == 0 }
    }

    var searchHistory = Variable([String]())

    init(provider: Networking, selectedScope: Observale<ScopeValues>) {
        self.provider = provider
        self.selectedScope = selectedScope
    }
    
    func getSearchResults(_ query: String) -> Observable<[(Subreddit?, Link?)]> {
        guard !query.isEmpty else { return NoDisposable.instance }    
        
        selectedScope
        .map { scope -> (RedditAPI, ScopeValues) in
            switch scope {
            case .Title:
                return (.SearchTitle(query: query), .Title)
            case .Subreddit:
                return (.SearchSubreddit(query: query), .Subreddit)
            }
        }
        .map { e -> [(Subreddit?, Link?)] in
            self.provider.request(e.0)
                .filterSuccessfulStatusCodes()
                .mapJSON()
                .map { json -> (Subreddit?, Link?) in
                    switch e.1 {
                    case .Title:
                        return linkParser(json: JSON(json)).map { (nil, $0) }
                    case .Subreddit:
                        return subredditsParser(json: JSON(json)).map { ($0, nil) }
                    }
                }
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
