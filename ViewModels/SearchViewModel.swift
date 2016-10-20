import Foundation
import RxSwift
import Moya

protocol SearchViewModelType {

}

class SearchViewModel: NSObject, SearchViewModelType {
    var selectedScope: Observable<ScopeValues>!
    var provider: Networking!

    init(provider: Networking, selectedScope: Observale<ScopeValues>) {
        self.provider = provider
        self.selectedScope = selectedScope
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
