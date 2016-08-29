//
//  SubredditCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-01.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

class SubredditCell: BaseTableViewCell {

    lazy var picture: UIImageView! = {
        return self.viewWithTag(1) as! UIImageView
    }()
    
    lazy var titleLabel: UILabel! = {
        return self.viewWithTag(2) as! UILabel
    }()
    
    lazy var descLabel: UILabel! = {
        return self.viewWithTag(3) as! UILabel
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.picture.image = .None
        self.titleLabel.text = .None
        self.descLabel.text = .None
    }
    
    func loadCell(subreddit: Subreddit) {
        
        if let headerUrl = subreddit.headerImage {
            self.picture.sd_setImageWithURL(headerUrl, placeholderImage: UIImage(named: "placeholder"))
        }
        
        self.titleLabel.text = subreddit.title
        self.descLabel.text = "\(subreddit.description)"
    }
    
}
