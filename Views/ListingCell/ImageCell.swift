//
//  TopicCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
#if !RX_NO_MODULE
import RxSwift
#endif


class ImageCell: ListingTableViewCell {
    
    var tapOnPicture: Observable<NSDate>!

    override func configure() {
        super.configure()
        
        let tap = UITapGestureRecognizer()
        self.picture?.addGestureRecognizer(tap)
        
        tapOnPicture = tap
            .rx_event
            .map { _ in
                return NSDate()
            }
        
        viewModel
            .map { viewModel -> NSURL? in
                return viewModel.resourceURL
            } 
            .doOn {[weak self] _ in
                self?.picture?.contentMode = .ScaleAspectFill
                self?.picture?.clipsToBounds = true
                self?.picture?.image = self?.placeholder
            }
            .map { element -> NSURL? in
                if let value = element {
                    return value
                } else {
                    return nil
                }
            }
            .subscribeNext {[weak self] URL in
                if let URL = URL {
                    self?.picture?.sd_setImageWithURL(URL, placeholderImage: self?.placeholder)
                }
            }
            .addDisposableTo(reuseBag)
    }
    
}
