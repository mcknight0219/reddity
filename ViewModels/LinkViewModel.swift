import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif


class LinkViewModel: NSObject {

    static let allSupportedImage = ["png", "jpg", "jpeg", "bmp", "gif"]
    static let allSupportedVideo = ["mp4", "gifv"]
    
    // MARK: Public properties

    lazy var cellIdentifier: String = {
        if let _ = self.link.selfType.associatedValue {
            return "TextCell"
        }
        if let _ = self.media {
            return "ImageCell"
        }

        return "NewsCell"
    }()
    
    lazy var cellHeight: CGFloat = {
        return self.cellIdentifier == "ImageCell" ? 270.0 : 180.0
    }()
    
    lazy var title: String = {
        return self.link.title
    }()
    lazy var accessory: String = {
        let link = self.link
        let score = link.ups - link.downs
        return "\(link.subreddit)・\(link.createdAt.daysAgo)・\(score)"
    }()
    lazy var previewURL: NSURL? = {
        return self.media?.URL   
    } ()
    
    private let media: Media! 
    private let link: Link!
    init(link: Link) {
        self.link = link
        self.media = Media(link.url)
        super.init()
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

