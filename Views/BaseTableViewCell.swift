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
        commonInit()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.applyTheme()
        self.selectionStyle = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    func applyTheme() {
        guard self.backgroundColor != UIColor.clearColor() else { return }
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.backgroundColor = UIColor(colorLiteralRed: 28/255, green: 28/255, blue: 37/255, alpha: 1.0)
            self.textLabel?.textColor = UIColor(colorLiteralRed: 79/255, green: 90/255, blue: 119/255, alpha: 1.0)
            self.detailTextLabel?.textColor = FlatBlueDark()
        } else {
            self.backgroundColor = UIColor.whiteColor()
            self.textLabel?.textColor = UIColor.blackColor()
            self.detailTextLabel?.textColor = UIColor(colorLiteralRed: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        }
    }
}
