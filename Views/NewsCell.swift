//
//  NewsCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-21.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

    lazy var titleLabel: UILabel! = {
       return self.viewWithTag(1) as! UILabel
    }()
    
    lazy var descriptionLabel: UILabel! = {
        return self.viewWithTag(2) as! UILabel
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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func loadTopic(aTopic: Link) {
        self.titleLabel.text = aTopic.title
        self.infoLabel.text = "\(aTopic.subreddit)・\(String(aTopic.numberOfComments))"
        self.dateLabel.text = NSDate.describePastTimeInDays(aTopic.createdAt)
        let downloadUrl = aTopic.mostSuitableThumbnailUrl(Int(UIScreen.mainScreen().bounds.width)) ?? aTopic.url
        
        if isImageFileUri(downloadUrl) {
            ImageDownloader.sharedInstance.downloadImageAt(downloadUrl) { (image) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    self.picture.contentMode = .ScaleAspectFill
                    self.picture.clipsToBounds = true
                    self.picture.image = image
                }
            }
            
            return
        }
        
        // If it's wikipedia, just show the logo as image.
        // TODO Create an 'exception class to handle such cases'
        if isWikipedia(downloadUrl) {
            dispatch_async(dispatch_get_main_queue()) {
                self.picture.contentMode = .ScaleAspectFill
                self.picture.clipsToBounds = true
                UIView.animateWithDuration(0.3) {
                    self.picture.image = UIImage(named: "WikipediaLogo")
                }
            }
            
            return
        }
        
        LightBox(withUrl: downloadUrl.absoluteString).load() { (_, desc, imageUrl) -> Void in
            if let desc = desc { self.descriptionLabel.text = desc }
            if let url = imageUrl {
                if url.isEmpty {
                    return
                }
                
                ImageDownloader.sharedInstance.downloadImageAt(NSURL(string: url)!) { (image) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.picture.contentMode = .ScaleAspectFill
                        self.picture.clipsToBounds = true
                        self.picture.image = image
                    }
                }
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
    
    func isImageFileUri(url: NSURL) -> Bool {
        if let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false), let path = components.path {
            let pattern = try! NSRegularExpression(pattern: "^.+\\.(jpg|png|jpeg)$", options: .CaseInsensitive)
            let result = pattern.matchesInString(path, options: [], range: NSMakeRange(0, path.characters.count))
            
            return result.count > 0
        }
        
        return false
    }

}