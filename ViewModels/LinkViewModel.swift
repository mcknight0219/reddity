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
        if _ = self.link.selfType.associatedValue {
            return "TextCell"
        }
        
        if let _ = self.media {
            return "ImageCell"
        }

        return "NewsCell"
    }()
    lazy var cellHeight: CGFloat = {
       return 88
    }()
    lazy var title: String = {
        return self.link.title
    }
    lazy var accessory: String = {
        let link = self.link
        let score = link.up - link.down
        return "\(link.subreddit)・\(link.createdAt.daysAgo)・\(score)"
    }
    lazy var previewURL: NSURL? = {
        return self.media?.URL   
    } 
    
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
            swithc self {
            case Image(let x):
                return x
            case Video(let x):
                return x
            }
        }

        var URL: NSURL? {
            if let url = self.associatedValue {
                return NSURL(string: url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            }
            return nil
        }


        init?(_ url: String) {
            let ext = NSString(string: url).pathExtension.lowercaseString
            
            if !ext.isEmpty {
                if allSupportedImage.contains(ext) {
                    self = .Image(URL: url)
                } else if allSupportedVideo.contains(ext) {
                    if ext == "gifv" {
                        url = url.substringToIndex(url.endIndex.advancedBy(-4)) + "mp4"
                    }
                    self = .Video(URL: url)
                } 
            } else {
                if url.test(Config.ImgurResourcePattern) {
                    url = url + ".png"
                    self = .Image(URL: url)
                } else {
                    return nil
                }
                
            }
        } 
    }
}

extension LinkViewModel {

}

