import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif


enum CellType {
    case Text
    case News
    case Image
    case Video

    var identifier: String {
        switch self {
        case Text:
            return "TextCell"
        case News:
            return "NewsCell"
        case Image:
            return "ImageCell"
        case Video:
            return "VideoCell"
        }
    }
}

class LinkViewModel: NSObject {

    static let allSupportedImage = ["png", "jpg", "jpeg", "bmp", "gif"]
    static let allSupportedVideo = ["mp4", "gifv"]
    
    // MARK: Public properties

    lazy var cellType: CellType = {
        if let _ = self.link.selfType.associatedValue {
            return .Text
        }
        if let URL = self.resourceURL {
            if URL.pathExtension! == "mp4" {
                return .Video
            }
            return .Image
        }
        return .News
    }()
    
    lazy var cellHeight: CGFloat = {
        switch self.cellType {
        case .Image, .Video:
            return 300.0
        default:
            return 220.0
        }
    }()
    
    lazy var title: String = {
        return self.link.title
    }()

    lazy var accessory: String = {
        return "Comments: \(self.link.numberOfComments)"
    }()
    
    lazy var subreddit: String = {
        return self.link.subreddit
    }()
    
    lazy var date: String = {
        return self.link.createdAt.minutesAgo()
    }()
    
    lazy var URL: String = {
        return self.link.url
    } ()
    
    var resourceURL:  NSURL? 
    var thumbnailURL: NSURL?
    // For external links we try to fetch the content and parse out
    // thumbnail url.
    var websiteThumbnailURL: Observable<NSURL?> = Observable.empty()
    
    var presentImage: Observable<Bool>!
    
    var selfText: Observable<String> = Observable.empty()
    
    var link: Link!
    init(link: Link) {
        super.init()
        self.link = link
        self.resourceURL  = Media.init(URL)?.URL
        self.thumbnailURL = Media.init(link.thumbnail ?? "")?.URL
        
        if case .News = self.cellType {
            websiteThumbnailURL = LightBoxNetworkModel(url: URL).thumbnailURL        
        }
        
        if case .Text = self.cellType, case .SelfText(let text) = self.link.selfType {
            selfText = Observable.just(text)
        }
    }

    // Archive the link
    func archive() {
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate, let db = delegate.database {
            let data = self.link.rawJsonString 
            try! db.executeUpdate("INSERT INTO timeline_history (data) values (?)", values: nil)
        } else {
            print("Couldn't find database instance")
        }
    }

    enum Media {
        case Image(URL: String)
        case Video(URL: String)

        var associatedValue: String {
            switch self {
            case Image(let x):
                return x
            case Video(let x):
                return x
            }
        }

        var URL: NSURL? {
            return NSURL(string: self.associatedValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        }

        init?(_ url: String) {
            let ext = NSString(string: url).pathExtension.lowercaseString
            
            if !ext.isEmpty {
                if allSupportedImage.contains(ext) {
                    self = .Image(URL: url)
                } else if allSupportedVideo.contains(ext) {
                    var tmp: String = url
                    if ext == "gifv" {
                        tmp = url.substringToIndex(url.endIndex.advancedBy(-4)) + "mp4"
                    }
                    self = .Video(URL: tmp)
                } else {
                    return nil
                }
            } else {
                if url.test(Config.ImgurResourcePattern) {
                    self = .Image(URL: url + ".png")
                } else {
                    return nil
                }
            }
        } 
    }
}

