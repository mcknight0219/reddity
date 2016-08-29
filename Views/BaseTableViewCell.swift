//
//  BaseTableViewCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-02
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class BaseTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style, reuseIdentifier)
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    func applyTheme() {
        if ThemeManager.defaultManager().currentTheme == "Dark" {
            self.backgroundColor = FlatDark()
            self.textLabel.textColor = FlatWhite()
            self.detailTextLabel.textColor = FlatWhiteDark()

            let bg = UIView()
            bg.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            self.selectedBackgroundView = bg
        } else {
            self.backgroundColor = FlatWhite()
            self.textLabel.textColor = FlatBlackDark()
            self.detailTextLabel.textColor = FlatBlack()

            let bg = UIView()
            bg.backgroundColor = UIColor(colorLiteralRed: 252/255, green: 126/255, blue: 15/255, alpha: 0.05)
            self.selectedBackgroundView = bg
        }
    }
}
