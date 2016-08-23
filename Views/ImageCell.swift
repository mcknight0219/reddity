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

class ImageCell: UITableViewCell {
    
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
    
    var progressLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ImageCell.applyTheme), name: "ThemeManagerDidChangeThemeNotification", object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
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
        self.infoLabel.text = "\(aTopic.subreddit)・\(String(aTopic.numberOfComments))"
        self.dateLabel.text = NSDate.describePastTimeInDays(aTopic.createdAt)
        
        let isGif = aTopic.isUrlGif()
        var downloadUrl: NSURL = aTopic.url
        if let url = aTopic.mostSuitableThumbnailUrl(Int(UIScreen.mainScreen().bounds.width)) {
            if !isGif { downloadUrl = url }
        }

        let placeholder = UIImage.imageFilledWithColor(FlatWhite())

        if !isGif {
            self.picture.sd_setImageWithURL(downloadUrl, placeholderImage: placeholder)
        } else {
            
        }
    }
    
    // MARK: Theme
    
    func applyTheme() {
    }
}
