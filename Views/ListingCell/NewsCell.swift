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
import Kingfisher

class NewsCell: ListingTableViewCell {

    var tapOnPicture: Observable<NSDate>!
    
    override func configure() {
        super.configure()

        let tap = UITapGestureRecognizer()
        self.picture?.addGestureRecognizer(tap)
        
        tapOnPicture = tap
          .rx.event
          .map { _ in
            return NSDate()
          }

        viewModel
            .map { vm in
                vm.thumbnailURL
            }
            .do(onNext: { _ in
                self.picture?.contentMode = .scaleAspectFill
                self.picture?.clipsToBounds = true
                self.picture?.image = UIImage.imageFilledWithColor(color: FlatWhite())
            })
            .subscribe(onNext: { thumbnail in
                self.picture?.kf.setImage(with: thumbnail, placeholder: self.placeholder)
                return
            })
            .addDisposableTo(reuseBag)
    }
    
}
