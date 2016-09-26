//
//  TopicCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SDWebImage
import ChameleonFramework

class ImageCell: BaseTableViewCell {
    
    lazy var picture: UIImageView! = {
        return self.viewWithTag(1) as! UIImageView
    }()
    
    lazy var titleLabel: UILabel! = {
        return self.viewWithTag(2) as! UILabel
    }()
    
    lazy var infoLabel: UILabel! = {
        return self.viewWithTag(3) as! UILabel
    }()
    
    lazy var dateLabel: UILabel! = {
        return self.viewWithTag(4) as! UILabel
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ImageCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.picture.image = .None
        self.titleLabel.text = .None
    }
    
    func loadTopic(aTopic: Link) {
        self.titleLabel.text = aTopic.title
        self.infoLabel.text = "\(aTopic.subreddit)"
        self.dateLabel.text = "\(NSDate.describePastTimeInDays(aTopic.createdAt))・\(String(aTopic.numberOfComments))"
        
        let placeholder = UIImage.imageFilledWithColor(FlatWhite())
        var url: NSURL = aTopic.url
        
        var _progress: ((Int, Int) -> Void)?
        var _completion: SDWebImageCompletionBlock?
        let _thumbnail = aTopic.mostSuitableThumbnailUrl(Int(UIScreen.mainScreen().bounds.width)) 
        
        
        if aTopic.isURLGif() {
            /*
            self.progressView = ProgressPieView(frame: CGRectMake(0, 0, 35, 35))
            self.picture.addSubview(self.progressView)
            self.progressView.center = self.picture.center

            _progress = { [weak self] (received, expected) in
                self?.progressView?.progress = Float(received) / Float(expected)
            }

            _completion = { [weak self] (_, error, _, _)  in
                self?.progressView?.removeFromSuperview()
            }
            */
        } else {
            if let thumbnail = _thumbnail { url = thumbnail }
        }

        self.picture.sd_setImageWithURL(url, placeholderImage: placeholder, options: [], progress: _progress, completed: _completion)
    }
    
    override func applyTheme() {
        super.applyTheme()
        
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.titleLabel?.textColor = UIColor(colorLiteralRed: 0.62, green: 0.65, blue: 0.72, alpha: 1.0)
            self.infoLabel?.textColor = FlatWhiteDark()
            self.dateLabel?.textColor = UIColor.lightGrayColor()
        } else {
            self.titleLabel?.textColor = UIColor.blackColor()
            self.infoLabel?.textColor = UIColor(colorLiteralRed: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            self.dateLabel?.textColor = UIColor(colorLiteralRed: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        }
    }
}
