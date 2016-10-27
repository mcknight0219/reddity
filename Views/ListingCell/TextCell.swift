//
//  TextCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-21.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class TextCell: ListingTableViewCell {
    // Configure cell with view model
    override func configure() {
        super.setup()
        // Map view model to title
        self.viewModel
            .map { viewModel -> String in
                return viewModel.title
            }
            .bindTo(self.title.rx_text)
            .addDisposableTo(disposeBag)

        self.viewModel
            .map { viewModel -> String in
                return viewModel.accessory
            }
            .bindTo(self.accessory.rx_text)
            .addDisposableTo(disposeBag)
    }
 }
