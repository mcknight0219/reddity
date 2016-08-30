//
//  TextCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-21.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class TextCell: UITableViewCell {
    
    lazy var titleLabel: UILabel! = {
        return self.viewWithTag(1) as! UILabel
    }()

    lazy var descLabel: UILabel! = {
        return self.viewWithTag(2) as! UILabel
    }()

    lazy var infoLabel: UILabel! = {
       self.viewWithTag(3) as! UILabel
    }()
    
    lazy var dateLabel: UILabel! = {
        self.viewWithTag(4) as! UILabel
    }()


    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TextCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = .None
        self.descLabel.text = .None
    }
    
    func loadTopic(aTopic: Link) {
        self.titleLabel.text = aTopic.title
        self.infoLabel.text = "\(aTopic.subreddit)・\(String(aTopic.numberOfComments))"
        self.dateLabel.text = NSDate.describePastTimeInDays(aTopic.createdAt)
        
        switch aTopic.selfType {
        case let .SelfText(text):
            self.descLabel.text = text
        default:
            break
        }
    }
    
    func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.backgroundColor = FlatBlack()
            self.titleLabel?.textColor = UIColor(colorLiteralRed: 0.62, green: 0.65, blue: 0.72, alpha: 1.0)
            self.descLabel?.textColor = FlatWhiteDark()
            self.infoLabel?.textColor = FlatWhite()
            self.dateLabel?.textColor = FlatWhite()
            
            let bg = UIView()
            bg.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            self.selectedBackgroundView = bg
        } else {
            self.backgroundColor = UIColor.whiteColor()
            self.titleLabel?.textColor = UIColor.blackColor()
            self.descLabel?.textColor = UIColor(colorLiteralRed: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            self.infoLabel?.textColor = UIColor(colorLiteralRed: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            self.dateLabel?.textColor = UIColor(colorLiteralRed: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            
            let bg = UIView()
            bg.backgroundColor = UIColor(colorLiteralRed: 252/255, green: 126/255, blue: 15/255, alpha: 0.05)
            self.selectedBackgroundView = bg
        }
    }
}
