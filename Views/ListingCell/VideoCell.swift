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
            self.video.player = player
        }
    }

    override func configure() {
        super.configure()

        video.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        viewModel
        .map { viewModel -> NSURL? in
            return viewModel.resourceURL
        }
        .observeOn(MainScheduler.instance)
        .subscribeNext { [weak self] URL in
            if let weakSelf = self, let URL = URL {
                if let player = player {
                    let newItem = AVPlayerItem(URL: URL)
                    player.replaceCurrentItem(with: newItem)
                } else {
                    player = AVPlayer(URL: URL)
                    // Loop
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoCell.loop), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
                    // automatically play when ready
                    player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
                    // Update time label

                }
            }

        }
        .addDisposableTo(reuseBag)
    }

    func loop() {
        self.player.seekToTime(kCMTimeZero)
        self.player.play()
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let player = object as? AVPlayer {
            if player.status == .readyToPlay {
                player.play()
            }
        }    
    }
}
