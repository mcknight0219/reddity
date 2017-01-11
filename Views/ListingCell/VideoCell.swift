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
                if let player = weakSelf.player {
                    let newItem = AVPlayerItem(URL: URL)
                    player.replaceCurrentItemWithPlayerItem(newItem)
                    if let token = weakSelf.observeToken {
                        weakSelf.player!.removeTimeObserver(token)
                    }
                } else {
                    weakSelf.player = AVPlayer(URL: URL)
                    // Loop
                    NSNotificationCenter.defaultCenter().addObserver(weakSelf, selector: #selector(VideoCell.loop), name: AVPlayerItemDidPlayToEndTimeNotification, object: weakSelf.player!.currentItem)
                    // automatically play when ready
                    weakSelf.player!.addObserver(weakSelf, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
                }
                
                // Update time label
                let interval = CMTime(seconds: 0.5,
                    preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                weakSelf.observeToken = weakSelf.player!.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) { [weak self] time in
                    if let weakSelf = self {
                        
                    }
                }
            }

        }
        .addDisposableTo(reuseBag)
    }

    func loop() {
        self.player?.seekToTime(kCMTimeZero)
        self.player?.play()
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let player = object as? AVPlayer {
            if player.status == .ReadyToPlay {
                player.play()
            }
        }    
    }
}
