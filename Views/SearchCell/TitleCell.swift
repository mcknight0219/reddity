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

class TitleCell: UITableViewCell {
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

    func applyTheme() {
        let theme = CellTheme()!
    
        self.title?.textColor = theme.mainTextColor
        self.info?.textColor  = theme.accessoryTextColor
        self.backgroundColor  = theme.backgroundColor
    }

    func loadTitle(aLink: Link) {
    }

}
