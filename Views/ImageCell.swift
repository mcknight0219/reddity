//
//  TopicCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class ImageCell: UITableViewCell {
    
    
    lazy var picture: UIImageView! = {
        return self.viewWithTag(1) as! AnimatableImageView
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ImageCell.applyTheme), name: "ThemeManagerDidChangeThemeNotification", object: nil)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadTopic(aTopic: Link) {
        self.titleLabel.text = aTopic.title
        self.infoLabel.text = "\(aTopic.subreddit)・\(String(aTopic.numberOfComments))"
        self.dateLabel.text = NSDate.describePastTimeInDays(aTopic.createdAt)
        
        var isGif = aTopic.isUrlGif()
        var downloadUrl: NSURL = aTopic.url
        if !isGif && let url = aTopic.mostSuitableThumbnailUrl(Int(UIScreen.mainScreen().bounds.width)) {
            downloadUrl = url
        }

        if !isGif {
            ImageDownloader.sharedInstance.downloadImageAt(downloadUrl) { (image) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    self.picture.contentMode = .ScaleAspectFill
                    self.picture.clipsToBounds = true
                    self.picture.image = image    
                }
            }
        } else {
            // For gif, we show the thumbnail and progress
            ImageDownloader.sharedInstance.downloadImageWithProgressReport(downloadUrl, onProgress: { (fragment) -> Void in
                
                }, onFinish: { (data) -> Void in
                    })
        }
    }
    
    // MARK: Theme
    
    func applyTheme() {
    }
}
