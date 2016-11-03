//
//  NewsCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-21.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
import Moya

class NewsCell: ListingTableViewCell {
    override func configure() {
        super.configure()
        
        viewModel
            .flatMap { viewModel in
                return Observable.combineLatest(Observable.just(viewModel.thumbnailURL), viewModel.websiteThumbnailURL) {
                    return ($0, $1)
                }
            }
            .doOn { _ in
                self.picture?.contentMode = .ScaleAspectFill
                self.picture?.clipsToBounds = true
                self.picture?.image = UIImage.imageFilledWithColor(FlatWhite())
            }
            .subscribeNext { thumbnails in
                self.picture?.sd_setImageWithURL(thumbnails.0 ?? thumbnails.1, placeholderImage: self.placeholder)
            }
            .addDisposableTo(disposeBag)
    }
    
}
