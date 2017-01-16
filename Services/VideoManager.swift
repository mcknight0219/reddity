import AVFoundation
import RxSwift
import RxCocoa

final class VideoManager: NSObject {
    static let defaultManager = VideoManager()
    
    let cache = NSCache()

    func retrieveVideo(from URL: NSURL, fromCache: Bool = true) -> Observable<AVPlayerItem> {
        
        if fromCache, let item = cache.objectForKey(URL) {
            return Observable.just(item as! AVPlayerItem)
        }
        
        let item = AVPlayerItem(URL: URL)
        let asset = item.asset
        return Observable.create { observer in
            asset.loadValuesAsynchronouslyForKeys(["playable"]) {
                var error: NSError?
                let status = asset.statusOfValueForKey("playable", error: &error)
                switch status {
                case .Loaded:
                    observer.onNext(item)
                case .Failed:
                    observer.onError(error!)
                default:
                    observer.onCompleted()
                }
            }


            return AnonymousDisposable {
            
            }
        }
        
    }
}
