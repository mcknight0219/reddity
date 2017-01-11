import AVFoundation
#if !RX_NO_MODULE
  import RxSwift
#endif

final class VideoManager: NSObject {
    static let default = VideoManager()
    
    let cache = NSCache<NSURL, AVPlayerItem>()

    func retrieveVideo(from URL: NSURL, fromCache: Bool = true) -> Observable<AVPlayerItem> {
        if fromCache, let item = cache.objectForKey(URL) {
            return Observable.create.just(item)
        }

        let item = AVPlayerItem(URL: URL)
        return item.rx_observe(AVPlayerItemStatus.self, "status")
            .filter { $0 == .ReadyToPlay }
            .map { item }
            .doOn { cache.setObject($0.item, forKey: URL) }
    }    

    func clear() {
        self.cache.removeAllObjects()
    }
}
