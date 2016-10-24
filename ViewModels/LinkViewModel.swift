import Foundation

protocol LinkViewModelType {
   var title: Driver<String> 
   var image: Driver<NSURL>!

   var mediaType: Media
}

class LinkViewModel: NSObject, LinkViewModel {
    let link: Link!

    let allSupportedImage = ["png", "jpg", "jpeg", "bmp"]
    let allSupportedVideo = ["mp4", "gifv"]
    
    init(link: Link) {
        self.link = link
   
    }

    
    enum Media {
        case Image(URL: String)
        case Gif(URL: String)
        case Video(URL: String)
        case Unsupported

        init?(_ aString: String?) {
            guard var url = aString where !url.isEmpty else {
                self = .Unsupported
            }
            
            let ext = NSString(string: url).pathExtension.lowercaseString
            if !ext.isEmpty {
                if allSupportedImage.contains(ext) {
                    return .Image(url)
                }

                if allSupportedVideo.contains(ext) {
                    if ext == "gifv" {
                        url = url.substringToIndex(url.endIndex.advanceBy(-4)) + "mp4"
                    }
                    return .Video(url)
                }

                if ext == "gif" {
                    return Gif(url)
                }

                return .Unsupported
            } eles {
                // Some url of format `https://www.imgur.com/aXfgd` actually
                // can be appended '.png' to make legit url
                if url.test(Config.ImgurResourcePattern) {
                    
                    url = url + ".png"
                    return .Image(url)
                }

                return .Unsupported
            }
        } 

        var URL: NSURL? {
            switch self {
            case .Image(let url), .Video(let url), .Gif(let url):
                return NSURL(string: URL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            default:
                return nil
            }
        }

    }
}

extension LinkViewModel {

}

