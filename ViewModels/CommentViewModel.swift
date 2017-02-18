import Foundation
import SwiftyJSON
#if !RX_NO_MODULE
import RxSwift
#endif

protocol CommentViewModelType {
    var numberOfComments: Int { get }
    var showSpinner: Observable<Bool>! { get }
    var updatedContents: Observable<Date>! { get }
    
    func commentAtIndexPath(_: IndexPath, _: Comment?) -> Comment?
}

class CommentViewModel: NSObject, CommentViewModelType {

    private var provider: Networking!
    private let link: Link!
    private let reuseBag = DisposeBag()
    
    var numberOfComments: Int {
        get {
            return comments.value.count
        }
    }
    
    var comments = Variable([Comment]())
    var showSpinner: Observable<Bool>!
    var updatedContents: Observable<Date>! {
        get {
            return self.comments
                .asObservable()
                .filter {$0.count > 0 }
                .map { _ in Date() }
        }
    }
    
    init(aLink: Link, provider: Networking) {
        self.link = aLink
        self.provider = provider
        super.init()
        
        self.setup()
    }
    
    private func setup() {
        self.provider.request(action: .Comment(subreddit: link.subreddit, id: link.id))
            .filterSuccessfulStatusCodes()
            .map { response in
                let json = JSON(data: response.data)
                let comments = commentsParser(json: json)
                return comments
            }
            .bindTo(comments)
            .addDisposableTo(reuseBag)
        
        self.showSpinner = self.comments
            .asObservable()
            .map { comments in
                return comments.count == 0
            }
        
    }
}

extension CommentViewModel {
    func commentAtIndexPath(_ indexPath: IndexPath, _ p: Comment?) -> Comment? {
        if let pc = p {
            if pc.numberOfReplies == 0 {
                return nil
            }

            return pc.replies[indexPath.row]
        } 

        return self.comments.value[indexPath.row]
    }

}
