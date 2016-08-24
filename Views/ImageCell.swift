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
    
    var progressView: ProgressPieView!
    
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
        
        let placeholder = UIImage.imageFilledWithColor(FlatWhite())
        var url: NSURL = aTopic.url
        
        var _progress: ((Int, Int) -> Void)?
        var _completion: ((UIImage, NSError, SDImageCacheType, NSURL) -> Void)
        var _thumbnail = aTopic.mostSuitableThumbnailUrl(Int(UIScreen.mainScreen().bounds.width)) 
        
        if aTopic.isURLGif() {
            if let thumbnail = _thumbnail { placeholder = thumbnail }
            self.progressView = ProgressPieView(frame: CGRectMake(0, 0, 35, 35))
            self.picture.addSubview(self.progressView)
            self.progressView.center = self.picture.center

            _progress = (received, expected) { [weak self] in
                self.progressView?.progress = Double(received) / Double(expected)
            }

            _completion = (_, error, _, _) { [weak self] in
                self.progressView?.removeFromSuperview()
            }
        } else {
            if let thumbnail = _thumbnail { url = thumbnail }
        }

        self.picture.sd_setImageWithURL(url, placeholderImage: placeholder, options: nil, progress: _progress, completed: _completion)
    }
}
