import UIKit
import RxSwift
import RxCocoa

enum CellType {
    case text
    case news
    case image
    case video

    var identifier: String {
        switch self {
        case .text:
            return "TextCell"
        case .news:
            return "NewsCell"
        case .image:
            return "ImageCell"
        case .video:
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
            return .text
        }
        if let URL = self.resourceURL {
            if URL.pathExtension == "mp4" {
                return .video
            }
            return .image
        }
        return .news
    }()
    
    lazy var cellHeight: CGFloat = {
        switch self.cellType {
        case .image, .video:
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
    
    lazy var url: String = {
        return self.link.url
    } ()
    
    var resourceURL:  URL?
    var thumbnailURL: URL?
    var presentImage: Observable<Bool>!
    
    var selfText: Observable<String> = Observable.empty()
    
    var link: Link!
    init(link: Link) {
        super.init()
        self.link = link
        self.resourceURL  = Media.init(url)?.url
        self.thumbnailURL = Media.init(link.thumbnail ?? "")?.url
        
        if case .text = self.cellType, case .selfText(let text) = self.link.selfType {
            let lines = text.breaksIntoLines(constrained: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: CGFloat.greatestFiniteMagnitude), font: UIFont(name: "Helvetica Neue", size: 16)!)
            if lines.count < 5 {
                selfText = Observable.just(text)
            } else {
                selfText = Observable.just(lines[0...4].reduce("", { $0 + $1 }))
            }
            
        }
    }

    // Archive the link
    func archive() {}

    enum Media {
        case image(url: String)
        case video(url: String)

        var associatedValue: String {
            switch self {
            case .image(let x):
                return x
            case .video(let x):
                return x
            }
        }

        var url: URL? {
            return URL(string: associatedValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        }

        init?(_ url: String) {
            let ext = NSString(string: url).pathExtension.lowercased()
            
            if !ext.isEmpty {
                if allSupportedImage.contains(ext) {
                    self = .image(url: url)
                } else if allSupportedVideo.contains(ext) {
                    var tmp: String = url
                    if ext == "gifv" {
                        tmp = url.substring(to: url.index(url.endIndex, offsetBy: -4)) + "mp4"
                    }
                    self = .video(url: tmp)
                } else {
                    return nil
                }
            } else {
                let regex = try! NSRegularExpression(pattern: Config.ImgurResourcePattern, options: [])
                
                if !regex.matches(in: url, options: [], range: NSRange(location: 0, length: url.characters.count)).isEmpty {
                    self = .image(url: url + ".png")
                } else {
                    return nil
                }
            }
        } 
    }
}

