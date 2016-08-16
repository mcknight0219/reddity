//
//  TopicCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import Gifu
import ChameleonFramework

class ImageCell: UITableViewCell {
    
    lazy var picture: AnimatableImageView! = {
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
    
    var progressLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ImageCell.applyTheme), name: "ThemeManagerDidChangeThemeNotification", object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let lineHeight: CGFloat = 4
        progressLayer = CAShapeLayer()
        progressLayer.frame.size = CGSizeMake(picture.frame.width, lineHeight)
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, lineHeight / 2))
        path.addLineToPoint(CGPointMake(picture.frame.width, lineHeight / 2))
        progressLayer.lineWidth = lineHeight
        progressLayer.path = path.CGPath
        progressLayer.strokeColor = FlatOrange().CGColor
        progressLayer.lineCap = "butt"
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 0
        picture.layer.addSublayer(progressLayer)
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
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.hidden = true
        progressLayer.strokeEnd = 0
        CATransaction.commit()
        
        let isGif = aTopic.isUrlGif()
        var downloadUrl: NSURL = aTopic.url
        if let url = aTopic.mostSuitableThumbnailUrl(Int(UIScreen.mainScreen().bounds.width)) {
            if !isGif { downloadUrl = url }
        }

        let placeholder = UIImage.imageFilledWithColor(FlatGray())

        if !isGif {
            self.picture.setImageWithURL(downloadUrl, placeholder: placeholder, manager: RTWebImageManager.sharedManager, progress: { (recv, expected) in
                if self.progressLayer.hidden {
                    self.progressLayer.hidden = false
                }
                let percentage = Float(recv) / Float(expected)
                dispatch_async(dispatch_get_main_queue()) {
                    self.progressLayer.strokeEnd = CGFloat(percentage)
                }
                }, completion: { (image, state) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.progressLayer.hidden = true
                    self.picture.contentMode = .ScaleAspectFill
                    self.picture.clipsToBounds = true
                    self.picture.image = image
                }
            })
        } else {
            
        }
    }
    
    // MARK: Theme
    
    func applyTheme() {
    }
}
