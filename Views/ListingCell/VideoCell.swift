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

    override func configure() {
        super.configure()

        video!.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        viewModel
        .map { viewModel -> URL? in
            return viewModel.resourceURL
        }
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] url in
            if let weakSelf = self, let url = url {
                if weakSelf.player == nil {
                    weakSelf.player = AVPlayer()
                }

                let player = weakSelf.player!

                VideoManager.defaultManager.retrieveVideo(from: url)
                  .subscribeOn(MainScheduler.instance)
                  .subscribe(onNext: { item in
                      player.replaceCurrentItem(with: item)
                  })
                  .addDisposableTo(weakSelf.reuseBag)

 
                player.rx.observe(AVPlayerStatus.self, "status")
                  .subscribeOn(MainScheduler.instance)
                  .filter { $0 == .readyToPlay }
                  .subscribe { _ in
                      // Stop the spinner
                      weakSelf.video!.stopAnimate()
                      weakSelf.video!.playVideo()
                  }
                  .addDisposableTo(weakSelf.reuseBag)
                
                player.rx.observe(Float.self, "rate")
                    .subscribeOn(MainScheduler.instance)
                    .filter { $0 == 0 }
                    .subscribe { rate in
                        // show play again button
                        weakSelf.video?.playOrReplay()
                    }
                    .addDisposableTo(weakSelf.reuseBag)
                
            }

        })
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
        let seconds = String(format: "%02d", t.truncatingRemainder(dividingBy: 60))
        return "\(minutes):\(seconds)"
    }
}