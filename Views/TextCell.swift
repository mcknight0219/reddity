//
//  TextCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-21.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

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
        // Initialization code
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
    
}
