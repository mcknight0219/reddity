import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif


enum CellType {
    case Text
    case News
    case Image

    var identifier: String {
        switch self {
        case Text:
            return "TextCell"
        case News:
            return "NewsCell"
        case Image:
            return "ImageCell"
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
        if let _ = self.resource.value {
            return .Image
        }
        return .News
    }()
    
    lazy var cellHeight: CGFloat = {
        if case .Image = self.cellType { 
            return 270.0
        } else {
            return 180.0
        }
    }()
    
    lazy var title: String = {
        return self.link.title
    }()

    lazy var accessory: String = {
        let link = self.link
        let score = link.ups - link.downs
        return "\(link.subreddit)・\(link.createdAt.daysAgo)・\(score)"
    }()
    
    lazy var URL: String = {
        return self.link.url
    } ()
    
    var resourceURL:  NSURL? 
    var thumbnailURL: NSURL?
    // For external links we try to fetch the content and parse out
    // thumbnail url.
    var websiteThumbnailURL: Observable<NSURL?> = Observable.empty()
    
    private let link: Link!
    init(link: Link) {
        super.init()
        self.link = link
        self.resourceURL  = Media.init(URL)?.URL
        self.thumbnailURL = Media.init(link.thumbnail ?? "")?.URL

        if case .News = self.cellType {
            websiteThumbnailURL = LightBoxNetworkModel(URL).thumbnailURL.asObservable()
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

