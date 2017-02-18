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

    
    @IBOutlet weak var selfTextHeight: NSLayoutConstraint!

    override func prepareForReuse() {
        super.prepareForReuse()
        selfTextHeight.constant = 0
    }
    
    override func configure() {
        super.configure()
        
        viewModel
            .flatMap { viewModel in
                return viewModel.selfText
            }
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] text in
                if let weakSelf = self {
                    weakSelf.selfText!.text = text
                    weakSelf.selfText!.sizeToFit()
                    weakSelf.selfTextHeight.constant = weakSelf.selfText!.frame.height
                }
            })
            .addDisposableTo(reuseBag)
    }
}
