import UIKit
import ChameleonFramework
import FontAwesome_swift
#if !RX_NO_MODULE
import RxSwift
#endif

class CommentCell: UITableViewCell {
    
    lazy var commentLabel: CommentLabel! = {
        return self.viewWithTag(1) as! CommentLabel
    }()
    lazy var userLabel: UILabel! = {
        return self.viewWithTag(2) as! UILabel
    }()
    lazy var dateLabel: UILabel! = {
       return self.viewWithTag(5) as! UILabel
    }()
    lazy var commentButton: UIButton! = {
        return self.viewWithTag(3) as! UIButton
    }()
    lazy var upButton: UIButton! = {
        return self.viewWithTag(4) as! UIButton
    }()
    
    var reuseBag = DisposeBag()
    
    private var _expandRepliesPressed = PublishSubject<NSDate>()
    var expandRepliesPressed: Observable<NSDate> {
        return self._expandRepliesPressed.asObservable()
    }

    private var _votePressed = PublishSubject<NSDate>()
    var votePressed: Observable<NSDate> {
        return self._votePressed.asObservable()
    }

    var comment: Comment!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    /**
     Load the comment and set proper left margin
     */
    func configCellWith(aComment: Comment) {
        self.reuseBag = DisposeBag()
        
        self.comment = aComment
        commentLabel.text = aComment.text

        dateLabel.text = aComment.createdAt.minutesAgo()
        userLabel.text = aComment.user
        
        commentButton.setImage(UIImage(named: "comment"), forState: .Normal)
        commentButton.setTitle(" \(aComment.numberOfReplies)", forState: .Normal)
        
        upButton.setImage(UIImage(named: "unlike"), forState:  .Normal)
        upButton.setTitle(" \(aComment.ups)", forState: .Normal)

        // Map events
        Observable.just(aComment.numberOfReplies)
            .map { $0 > 0 }
            .bindTo(commentButton.rx_enabled)
            .addDisposableTo(reuseBag)

        commentButton.rx_tap
            .subscribeNext { [weak self] in 
                self?._expandRepliesPressed.onNext(NSDate())
            }
            .addDisposableTo(reuseBag)
        
        upButton.rx_tap 
            .subscribeNext { [weak self] in 
                self?._votePressed.onNext(NSDate())
            }
            .addDisposableTo(reuseBag)
    }
    
    func applyTheme() {
        let theme = CellTheme()!
        self.backgroundColor         = theme.backgroundColor
        self.commentLabel?.textColor = theme.mainTextColor
        self.commentButton.tintColor = UIColor.lightGrayColor()
        self.upButton.tintColor = UIColor.lightGrayColor()
    }

}
