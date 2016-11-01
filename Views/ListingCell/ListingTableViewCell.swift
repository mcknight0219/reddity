//
//  BaseTableViewCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-02
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

class ListingTableViewCell: UITableViewCell {

    // The title of link
    lazy var title: UILabel? = {
        return self.viewWithTag(1) as? UILabel
    }()

    // The date, subreddit and subreddit of link
    lazy var accessory: UILabel? = {
        return self.viewWithTag(2) as? UILabel 
    }()

    // Only specific to NewsCell and ImageCell
    lazy var picture: UIImageView? = {
         return self.viewWithTag(3) as? UIImageView 
    }()

    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    let placeholder = UIImage.imageFilledWithColor(UIColor.lightGrayColor())
    var viewModel = PublishSubject<LinkViewModel>()
    func setViewModel(viewModel: LinkViewModel) {
        self.viewModel.onNext(viewModel)
    }
    
    func configure() {
        self.applyTheme()
        self.selectionStyle = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ListingTableViewCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    
        // Common to all listing table view cell
        viewModel
            .map { viewModel -> String in
                return viewModel.title
            }
            .bindTo(self.title!.rx_text)
            .addDisposableTo(disposeBag)
        
        viewModel
            .map { viewModel -> String in
                return viewModel.accessory
            }
            .bindTo(self.accessory!.rx_text)
            .addDisposableTo(disposeBag)
    }

    @objc private func applyTheme() {
        let theme = CellTheme()!
        self.backgroundColor      = theme.backgroundColor
        self.title?.textColor     = theme.mainTextColor
        self.accessory?.textColor = theme.accessoryTextColor
    }
}
