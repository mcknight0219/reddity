//
//  NewsCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-21.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class NewsCell: ListingTableViewCell {

    lazy var titleLabel: UILabel! = {
       return self.viewWithTag(1) as! UILabel
    }()
    
    lazy var infoLabel: UILabel! = {
        return self.viewWithTag(3) as! UILabel
    }()

    lazy var picture: UIImageView! = {
        return self.viewWithTag(4) as! UIImageView
    }()
    
    lazy var dateLabel: UILabel! = {
       return self.viewWithTag(5) as! UILabel
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewsCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.picture.image = .None
        self.titleLabel.text = .None
    }
    
    func loadTopic(aTopic: Link) {
        self.titleLabel.text = aTopic.title
        self.titleLabel.numberOfLines = 4
        self.infoLabel.text = "\(opic.subreddit)"
        self.dateLabel.text = "\(NSDate.describePastTimeInDays(aTopic.createdAt))・\(String(aTopic.numberOfComments))"
        self.picture.contentMode = .ScaleAspectFill
        self.picture.clipsToBounds = true
        
        let thumbnail = aTopic.mostSuitableThumbnailUrl(Int(UIScreen.mainScreen().bounds.width))
        let placeholder = UIImage.imageFilledWithColor(FlatWhite())
        
        if let thumbnail = thumbnail {
            self.picture.sd_setImageWithURL(thumbnail, placeholderImage: placeholder)
            return
        }

        if isWikipedia(aTopic.url) {
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(0.1) {
                    self.picture.image = UIImage(named: "WikipediaLogo")
                }
            }
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.picture.image = placeholder
        }

        LightBox.sharedInstance.load(aTopic.url) { (_, _, imageURL) -> Void in
            if let imageURL = imageURL {
                self.picture.sd_setImageWithURL(imageURL)
            }
        }
    }
    
    func isWikipedia(url: NSURL) -> Bool {
        if let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false), let host = components.host {
            let pattern = try! NSRegularExpression(pattern: "^.+wikipedia.org$", options: .CaseInsensitive)
            let result = pattern.matchesInString(host, options: [], range: NSMakeRange(0, host.characters.count))
            
            return result.count > 0
        }
        
        return false
    }
    
    override func applyTheme() {
        super.applyTheme()
        
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.titleLabel?.textColor = UIColor(colorLiteralRed: 79/255, green: 90/255, blue: 119/255, alpha: 1.0)
            self.infoLabel?.textColor = UIColor.lightGrayColor()
            self.dateLabel?.textColor = UIColor.lightGrayColor()
        } else {
            self.backgroundColor = UIColor.whiteColor()
            self.titleLabel?.textColor = UIColor.blackColor()
            self.infoLabel?.textColor = UIColor(colorLiteralRed: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            self.dateLabel?.textColor = UIColor(colorLiteralRed: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        }
    }
}
