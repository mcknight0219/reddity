import Foundation
import Kanna
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
import Moya
#endif

class LightBoxNetworkModel: NSObject {
    var disposeBag = DisposeBag()
    var thumbnailURL: Variable<NSURL?>!

    init(url: String) {
        if URL = NSURL(url) {
            NSURLSession.sharedSession()
                .rx_response(NSURLRequest())
                .map { data, _ -> NSURL?
                    if let html = String(data: data!, encoding: NSUTF8StringEncoding),
                    let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                        if let url = doc.at_xpath("//meta[@property='og:image']/@content")?.text ?? doc.at_xpath("//meta[@name=\"thumbnail\"]/@content")?.text {
                            return NSURL(string: url)
                        }
                        return nil
                    }
                }
                .bindTo(thumbnailURL)
                .addToDisposable(self.disposeBag)

        } else {
            thumbnailURL.value = nil
        }
    }
}
