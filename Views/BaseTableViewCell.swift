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
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    func applyTheme() {
        guard self.backgroundColor != UIColor.clearColor() else { return }
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.backgroundColor = FlatBlack()
            self.textLabel?.textColor = FlatWhite()
            self.detailTextLabel?.textColor = FlatBlueDark()

            let bg = UIView()
            bg.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            self.selectedBackgroundView = bg
        } else {
            self.backgroundColor = UIColor.whiteColor()
            self.textLabel?.textColor = UIColor.blackColor()
            self.detailTextLabel?.textColor = UIColor(colorLiteralRed: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)

            let bg = UIView()
            bg.backgroundColor = UIColor(colorLiteralRed: 252/255, green: 126/255, blue: 15/255, alpha: 0.05)
            self.selectedBackgroundView = bg
        }
    }
}
