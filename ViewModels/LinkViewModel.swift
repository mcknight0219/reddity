import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

protocol LinkViewModelType {

}

class LinkViewModel: NSObject, LinkViewModelType {
    let link: Link!

    static let allSupportedImage = ["png", "jpg", "jpeg", "bmp"]
    static let allSupportedVideo = ["mp4", "gifv"]
    
    lazy var media: Media = {
        return Media(self.link.url)!
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
                }

                if allSupportedVideo.contains(ext) {
                    // replacing extension will play gifv file
                    if ext == "gifv" {
                        url = url.substringToIndex(url.endIndex.advancedBy(-4)) + "mp4"
                    }
                    self = .Video(URL: url)
                }

                if ext == "gif" {
                    self = Gif(URL: url)
                }

                self =  .Unsupported
            } else {
                // Some url of format `https://www.imgur.com/aXfgd` actually
                // can be appended '.png' to make legit url
                if url.test(Config.ImgurResourcePattern) {
                    
                    url = url + ".png"
                    self = .Image(URL: url)
                }

                self = .Unsupported
            }
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

