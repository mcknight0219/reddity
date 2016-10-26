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

enum ListingCellAppearance {
    case Dark
    case Light

    init?(themeManager: ThemeManager = ThemeManager.defaultManager()) {
        self = themManager.currentTheme == "Default"
            ? Light
            : Dark
    }

    var backgroundColor: UIColor {
        switch self {
        case Light: 
            return UIColor.whiteColor()
        case Dark:
            return UIColor(colorLiteralRed: 28/255, green: 28/255, blue: 37/255, alpha: 1.0)
        }
    }

    var mainTextColor: UIColor {
        switch self {
        case Light:
            return UIColor.blackColor()
        case Dark:
            return UIColor(colorLiteralRed: 79/255, green: 90/255, blue: 119/255, alpha: 1.0)
        }
    }

    var accessoryTextColor: UIColor {
        return UIColor.lightGrayColor()
    }
}

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    var viewModel = PublishSubject<LinkViewModel>()
    func setViewModel(viewModel: LinkViewModel) {
        self.viewModel.onNext(viewModel)
    }
    
    private func setup() {
        self.applyTheme()
        self.selectionStyle = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    private func applyTheme() {
        let appearance = ListingCellAppearance()
        self.backgroundColor      = appearance.backgroundColor
        self.title?.textColor     = appearance.mainTextColor
        self.accessory?.textColor = appearance.accessoryTextColor
    }
}
