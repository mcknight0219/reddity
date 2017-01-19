//
//  VideoCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2017/1/7.
//  Copyright © 2017年 Qiang Guo. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif
import AVFoundation
import AVKit

class VideoCell: ListingTableViewCell {

    var player: AVPlayer? {
        didSet {
            self.video!.player = player
        }
    }
    
    var observeToken: AnyObject?

    override func configure() {
        super.configure()

        video!.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        viewModel
        .map { viewModel -> NSURL? in
            return viewModel.resourceURL
        }
        .observeOn(MainScheduler.instance)
        .subscribeNext { [weak self] URL in
            if let weakSelf = self, let URL = URL {
                if weakSelf.player == nil {
                    weakSelf.player = AVPlayer()
                    /*
                    NSNotificationCenter.defaultCenter().addObserver(weakSelf, selector: #selector(VideoCell.stopVideoPlay), name: AVPlayerItemDidPlayToEndTimeNotification, object: weakSelf.player!.currentItem)
 */
                }

                let player = weakSelf.player!

                if let token = weakSelf.observeToken {
                    player.removeTimeObserver(token)
                }

                VideoManager.defaultManager.retrieveVideo(from: URL)
                  .subscribeOn(MainScheduler.instance)
                  .subscribeNext { item in
                      player.replaceCurrentItemWithPlayerItem(item)
                  }
                  .addDisposableTo(weakSelf.reuseBag)

 
                player.rx_observe(AVPlayerStatus.self, "status")
                  .subscribeOn(MainScheduler.instance)
                  .filter { $0 == .ReadyToPlay }
                  .subscribe { _ in
                      // Stop the spinner
                      weakSelf.video!.stopAnimate()
                      player.play()
                  }
                  .addDisposableTo(weakSelf.reuseBag)
                
                player.rx_observe(Float.self, "rate")
                    .subscribeOn(MainScheduler.instance)
                    .filter { $0 == 0 }
                    .subscribe { rate in
                        
                        // show play button
                        weakSelf.video?.playOrPause()
                    }
                    .addDisposableTo(weakSelf.reuseBag)
                
                // Update time label
                let interval = CMTime(seconds: 0.5,
                    preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                weakSelf.observeToken = player.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) { _ in
                }
            }

        }
        .addDisposableTo(reuseBag)
    }

    func stopVideoPlay() {
        if let player = self.player {
            if player.rate > 0 && player.error == nil {
                player.pause()
            }
        }
    }

    func labelizeCMTime(time: CMTime) -> String {
        let t = CMTimeGetSeconds(time)
        let minutes = String(t / 60)
        let seconds = String(format: "%02d", t % 60)
        return "\(minutes):\(seconds)"
    }
}
