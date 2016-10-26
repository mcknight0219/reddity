import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif


class LinkViewModel: NSObject {
    let link: Link!

    static let allSupportedImage = ["png", "jpg", "jpeg", "bmp"]
    static let allSupportedVideo = ["mp4", "gifv"]
    
    lazy var media: Media? = {
        return Media(self.link.url)
    }()

    // Very ugly and buggy
    lazy var cellIdentifier: String = {
        if case SelfType.SelfText(_) = self.link.selfType {
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
    
    init(link: Link) {
        self.link = link
        super.init()
        
        setup()
    }
    
    private func setup() {
        
    }

    enum Media {
        case Image(URL: String)
        case Gif(URL: String)
        case Video(URL: String)
        case Unsupported

        init?(_ aString: String?) {
            guard var url = aString where !url.isEmpty else {
                self = .Unsupported
                return
            }
            
            let ext = NSString(string: url).pathExtension.lowercaseString
            if !ext.isEmpty {
                if allSupportedImage.contains(ext) {
                    self = .Image(URL: url)
                    return
                }

                if allSupportedVideo.contains(ext) {
                    // replacing extension will play gifv file
                    if ext == "gifv" {
                        url = url.substringToIndex(url.endIndex.advancedBy(-4)) + "mp4"
                    }
                    self = .Video(URL: url)
                    return
                }

                if ext == "gif" {
                    self = Gif(URL: url)
                    return
                }

                self =  .Unsupported
                return
            } else {
                // Some url of format `https://www.imgur.com/aXfgd` actually
                // can be appended '.png' to make legit url
                if url.test(Config.ImgurResourcePattern) {
                    
                    url = url + ".png"
                    self = .Image(URL: url)
                    return
                }

            }
            
            return nil
        } 

        var URL: NSURL? {
            var url: String?
            if case .Image(let final) = self {
                url = final
            }
            else if case .Video(let final) = self {
                url = final
            }
            else if case .Gif(let final) = self {
                url = final
            }
            
            if let url = url {
                return NSURL(string: url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            }
            return nil
        }

    }
}

extension LinkViewModel {

}

