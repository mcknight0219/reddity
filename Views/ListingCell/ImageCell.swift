//
//  TopicCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif


class ImageCell: ListingTableViewCell {
    
    override func configure() {
        super.configure()
        
        viewModel
            .asObservable()
            .map { viewModel in
                viewModel.thumbnail.value ?? viewModel.resource.value
            }
            .subscribeNext { media in
            }
        
        
        
        viewModel
            .map { viewModel in
                return view
            }
            .doOn { _ in
                self.picture?.contentMode = .ScaleAspectFill
                self.picture?.clipsToBounds = true
            }
            .subscribeNext { (URL, placeholder) in
                self.picture?.sd_setImageWithURL(URL, placeholderImage: placeholder, options: [], progress: nil, completed: nil)
            }
            .addDisposableTo(disposeBag)
    }
    
}
