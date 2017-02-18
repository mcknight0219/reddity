import AVFoundation
import RxSwift
import RxCocoa

final class VideoManager: NSObject {
    static let defaultManager = VideoManager()
    
    let cache = NSCache<AnyObject, AnyObject>()

    func retrieveVideo(from url: URL, fromCache: Bool = true) -> Observable<AVPlayerItem> {
        
        if fromCache, let item = cache.object(forKey: url as AnyObject) {
            return Observable.just(item as! AVPlayerItem)
        }
        
        let item = AVPlayerItem(url: url)
        let asset = item.asset
        return Observable.create { observer in
            asset.loadValuesAsynchronously(forKeys: ["playable"]) {
                var error: NSError?
                
                let status = asset.statusOfValue(forKey: "playable", error: &error)
                switch status {
                case .loaded:
                    observer.onNext(item)
                case .failed:
                    observer.onError(error!)
                default:
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
        
    }
}
