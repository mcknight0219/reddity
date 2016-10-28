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
            .map { viewModel in
                return
            }
            .doOn { _ in
                self.picture?.contentMode = .ScaleAspectFill
                self.picture?.clipsToBounds = true
                self.picture?.image = UIImage.imageFilledWithColor(FlatWhite())
            }
        
    }
    
}