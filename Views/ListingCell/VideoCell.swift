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
    
    let controller = AVPlayerViewController()
    
    override func configure() {
        super.configure()
     
        viewModel
            .map { viewModel -> NSURL? in
                return viewModel.resourceURL
            }
            .observeOn(MainScheduler.instance)
            .doOn { [weak self] e in
                if let weakSelf = self, let URL = e.element {
                    let player = AVPlayer(URL: URL!)
                    weakSelf.controller.player = player
                    
                    weakSelf.video?.addSubview(weakSelf.controller.view)
                    weakSelf.controller.view.frame = weakSelf.video!.frame
                }
            }
            .subscribeNext { _ in
                self.controller.player!.play()
            }
            .addDisposableTo(reuseBag)
    }

}
