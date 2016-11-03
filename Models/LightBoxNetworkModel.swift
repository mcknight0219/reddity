import Foundation
import Kanna
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
import Moya
#endif

class LightBoxNetworkModel: NSObject {
    static let _cache = NSCache()
    var disposeBag = DisposeBag()

    var thumbnailURL: Observable<NSURL?>!

    init(url: String) {
        super.init()
        
        if let URL = NSURL(string: url) {
            thumbnailURL = self.thumbnailURL(URL) 
        } else {
            thumbnailURL = Observable<NSURL?>.empty()
        }
    }

    private func thumbnailURL(URL: NSURL) -> Observable<NSURL?> {
        return Observable.deferred {
            let maybeURL = LightBoxNetworkModel._cache.objectForKey(URL) as? NSURL
            let resultURL: Observable<NSURL?>

            if let u = maybeURL {
                resultURL = Observable.just(u)
            } else {
                
                resultURL = NSURLSession.sharedSession()
                    .rx_response(NSURLRequest(URL: URL))
                    .map { (data, _) -> NSURL? in
                        if let html = String(data: data, encoding: NSUTF8StringEncoding),
                        let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                            if let url = doc.at_xpath("//meta[@property='og:image']/@content")?.text ?? doc.at_xpath("//meta[@name=\"thumbnail\"]/@content")?.text {
                                return NSURL(string: url)
                            }
                        }
                        return nil
                    }
            }

            return resultURL.doOnNext({
                if let obj = $0 {
                    LightBoxNetworkModel._cache.setObject(obj, forKey: URL)
                }
                
            })
        }    
    }
}
