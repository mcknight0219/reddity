//
//  SubredditCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-01.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class SubredditCell: BaseTableViewCell {
    
    lazy var titleLabel: UILabel! = {
        return self.viewWithTag(2) as! UILabel
    }()
    
    lazy var descLabel: UILabel! = {
        return self.viewWithTag(3) as! UILabel
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ImageCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.titleLabel.text = .None
        self.descLabel.text = .None
    }
    
    func loadCell(subreddit: Subreddit) {
        
        self.titleLabel.text = subreddit.title
        self.descLabel.text = "\(subreddit.subscribers)"
    }
    
    override func applyTheme() {
        super.applyTheme()
        
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.titleLabel?.textColor  = FlatWhiteDark()
            self.descLabel?.textColor   = UIColor.lightGrayColor()
        } else {
            self.titleLabel?.textColor  = UIColor.blackColor()
            self.descLabel?.textColor   = UIColor.darkGrayColor()
        }
    }
    
}
