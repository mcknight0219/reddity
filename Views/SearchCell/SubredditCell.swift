//
//  SubredditCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-01.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class SubredditCell: UITableViewCell {
    
    lazy var titleLabel: UILabel! = {
        return self.viewWithTag(2) as! UILabel
    }()
    
    lazy var descLabel: UILabel! = {
        return self.viewWithTag(3) as! UILabel
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(SubredditCell.applyTheme), name: Notification.Name.onThemeChanged, object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.titleLabel.text = .none
        self.descLabel.text = .none
    }
    
    func loadCell(subreddit: Subreddit) {
        
        self.titleLabel.text = subreddit.title
        self.descLabel.text = "\(subreddit.subscribers)"
    }
    
    func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.titleLabel?.textColor  = FlatWhiteDark()
            self.descLabel?.textColor   = UIColor.lightGray
        } else {
            self.titleLabel?.textColor  = UIColor.black
            self.descLabel?.textColor   = UIColor.darkGray
        }
    }
    
}
