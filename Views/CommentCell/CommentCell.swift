//
//  CommentCell.swift
//  Reddity
//
//  Created by Qiang Guo on 16/9/12.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
import FontAwesome_swift

class CommentCell: UITableViewCell {

    @IBOutlet weak var bottomSectHeightConstraint: NSLayoutConstraint!
    
    lazy var commentLabel: CommentLabel! = {
        return self.viewWithTag(1) as! CommentLabel
    }()
    
    lazy var userLabel: UILabel! = {
        return self.viewWithTag(2) as! UILabel
    }()
    
    lazy var dateLabel: UILabel! = {
       return self.viewWithTag(5) as! UILabel
    }()
    
    lazy var commentButton: UIButton! = {
        return self.viewWithTag(3) as! UIButton
    }()

    lazy var upButton: UIButton! = {
        return self.viewWithTag(4) as! UIButton
    }()
    
    var comment: Comment!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    /**
     Load the comment and set proper left margin
     */
    func configCellWith(inout aComment: Comment) {
        self.comment = aComment
        commentLabel.text = aComment.text
        
        /*
        infoLabel.attributedText = NSMutableAttributedString(string: "・Reply・\(aComment.createdAt.daysAgo)", attributes: [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!])
       
        score.text = "\(aComment.score)"
        up.image = UIImage.fontAwesomeIconWithName(.ArrowUp, textColor: FlatGreenDark(), size: CGSizeMake(15, 15))
        down.image = UIImage.fontAwesomeIconWithName(.ArrowDown, textColor: FlatRedDark(), size: CGSizeMake(15, 15))
        */
        dateLabel.text = aComment.createdAt.minutesAgao()
        userLabel.text = aComment.user
        commentButton.setImage(UIImage.fontAwesomeIconWithName(.CommentO, textColor: UIColor.lightGrayColor(), size: CGSizeMake(20, 20)), forState: .Normal)
        commentButton.setTitle("\(aComment.totalReplies())", forState: .Normal)
        upButton.setImage(UIImage.fontAwesomeIconWithName(.ThumbsOUp, textColor: UIColor.lightGrayColor(), size: CGSizeMake(20, 20)), forState:  .Normal)
        upButton.setTitle("\(aComment.ups)", forState: .Normal)
    }
    
    func applyTheme() {
        let theme = CellTheme()!
        self.backgroundColor         = theme.backgroundColor
        self.commentLabel?.textColor = theme.mainTextColor
        self.commentButton.tintColor = UIColor.lightGrayColor()
        self.upButton.tintColor = UIColor.lightGrayColor()
    }

}
