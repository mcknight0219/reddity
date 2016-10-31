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

    lazy var placeholderImage: UIImage = {
        return UIImage.imageFilledWithColor(FlatWhite())
    }()
    
    override func configure() {
        super.configure()
    
        viewModel
            .map { viewModel -> NSURL? in
                return viewModel.thumbnailURL ?? viewModel.resourceURL 
            } 
            .doOn {[weak self] _ in
                self.picture?.contentMode = .ScaleAspectFill
                self.picture?.clipsToBounds = true
                self.picture?.image = placeholderImage 
            }
            .flatMap { (element) -> NSURL in
                if let value = element {
                    return Observable.just(element)
                } else {
                    return Observable.just()
                }
            }
            .subscribeNext {[weak self] url in
                self.picture?.sd_setImageWithURL(url)    
            }
            .addDisposableTo(disposeBag)
    }
    
}
