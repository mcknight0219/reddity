//
//  TitleCellTableViewCell.swift
//  Reddity
//
//  Created by Qiang Guo on 16/9/14.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
import SDWebImage

class TitleCell: BaseTableViewCell {

    lazy var thumbnail: UIImageView! = {
       return self.viewWithTag(1) as! UIImageView
    }()
    
    lazy var title: UILabel! = {
        return self.viewWithTag(2) as! UILabel
    }()

    lazy var info: UILabel! = {
        return self.viewWithTag(3) as! UILabel
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func applyTheme() {
        super.applyTheme()
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.title?.textColor = FlatWhiteDark()
            self.info?.textColor  = UIColor.lightGrayColor()

            let bg = UIView()
            bg.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            self.selectedBackgroundView = bg
        } else {
            self.title?.textColor = UIColor.blackColor()
            self.info?.textColor  = UIColor.darkGrayColor()

            let bg = UIView()
            bg.backgroundColor = UIColor(colorLiteralRed: 252/255, green: 126/255, blue: 15/255, alpha: 0.05)
            self.selectedBackgroundView = bg
        }
    }

    func loadTitle(aLink: Link) {
        self.title.text = aLink.title
        self.info.text  = "\(aLink.subreddit)・\(NSDate.describePastTimeInDays(aLink.createdAt))"

        let placeholder = UIImage.imageFilledWithColor(FlatWhite())
        self.thumbnail.contentMode = .ScaleAspectFill
        self.thumbnail.clipsToBounds = true
        self.thumbnail.sd_setImageWithURL(aLink.url, placeholderImage: placeholder)
    }

}
