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
    lazy var accesory: UILabel? = {
        return self.viewWithTag(2) as? UILabel 
    }()

    // Only specific to NewsCell and ImageCell
    lazy var preview: UIImageView? = {
         return self.viewWithTag(3) as? UIImageView 
    }()

    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    var viewModel = PublishSubject<LinkViewModel>()
    func setViewModel(viewModel: LinkViewModel) {
        self.viewModel.onNext(viewModel)
    }
    
    func configure() {
        self.applyTheme()
        self.selectionStyle = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    private func applyTheme() {
        let theme = CellTheme()
        self.backgroundColor      = theme.backgroundColor
        self.title?.textColor     = theme.mainTextColor
        self.accessory?.textColor = theme.accessoryTextColor
    }
}
